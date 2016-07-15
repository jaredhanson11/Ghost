import os
import psycopg2
import urlparse

from flask import Flask, render_template, jsonify
from flask_restful import Resource, Api, reqparse

app = Flask(__name__)
api = Api(app)

class signup(Resource):
    def post(self):
        '''
        POST /signup/
        BODY:
            {'username': <username>,
             'password': <password>}
        RESPONSE 'data':
            {'user_id': <user_id>,
             'username': <username>}
        '''

        request_parser = reqparse.RequestParser()
        request_parser.add_argument('username', type=str, location='json')
        request_parser.add_argument('password', type=str, location='json')
        request_args = request_parser.parse_args()
        username = request_args['username']
        password = request_args['password']

        print username, password
        database = _get_db()
        cursor = database.cursor()

        select_sql = \
                '''
                SELECT user_id FROM users WHERE username=%s
                '''
        insert_sql = \
                '''
                INSERT INTO users (username, password) VALUES (%s,%s)
                    RETURNING user_id
                '''

        cursor.execute(select_sql, (username,))
        query = cursor.fetchall()

        if not query:

            cursor.execute(insert_sql, (username, password))
            user_id = cursor.fetchone()[0]
            database.commit()
            data = {'user_id': user_id, 'username': username}
            print {'success': 1, 'data': data}
            return {'success': 1, 'data': data}
        else:
            data = {'error': 'The username is already in use.'}
            print {'success': 0, 'data': data}
            return {'success': 0, 'data': data}

class login(Resource):
    def post(self):
        '''
        POST /login/
        BODY:
            {'username': <username>,
             'password': <password>}
        RESPONSE 'data':
            {'user_id': <user_id>,
             'username': <username>}
        '''

        request_parser = reqparse.RequestParser()
        request_parser.add_argument('username', type=str, location='json')
        request_parser.add_argument('password', type=str, location='json')
        request_args = request_parser.parse_args()
        username = request_args['username']
        password = request_args['password']

        database = _get_db()
        cursor = database.cursor()

        select_sql = \
                '''
                SELECT user_id FROM users WHERE username=%s and password=%s
                '''

        cursor.execute(select_sql, (username, password))
        query = cursor.fetchone()

        if not query:
            data = {'error': 'The username/password combo is invalid.'}
            print {'success': 0, 'data': data}
            return {'success': 0, 'data': data}
        else:
            user_id = query[0]
            data = {'user_id': user_id, 'username': username}
            print {'success': 1, 'data': data}
            return {'success': 1, 'data': data}


class main_page(Resource):
    def get(self, userid):
        contacts = _get_contact(user_id)['contacts']
        convos = _get_convo(user_id)['convos']
        messages = _get_messages(user_id)['messages']

        user_interactions = set()

        for convo in convos.values():
            members_list = convo['members'].split(',')
            for member_id in members_list:
                if int(member_id) not in contacts:
                    known_user = _add_known_user(user_id, known_user_id)
                    contacts.update(known_user)

        data = {}
        data.update({'contacts': contacts})
        data.update({'convos': convos})
        data.update({'messages': messages})
        ret = {'success': data}

        return ret


def _add_known_user(user_id, known_user_id):

    database = _get_db()
    cursor = database.cursor()

    insert_sql = \
            '''
            INSERT INTO contacts (user_id, contact_id, is_contact)
                VALUES (%s, %s, 0)
            '''
    get_username_sql = \
            '''
            SELECT username FROM users WHERE user_id=%s
            '''

    cursor.execute(get_username_sql, (known_user_id))
    known_user_name = cursor.fetchone()[0]

    cursor.execute(insert_sql, (user_id, known_user_id))
    cursor.execute(insert_sql, (known_user_id, user_id))
    database.commit()

    return {int(known_user_id): {'contact_username': known_user_name,
                                 'is_contact': 0}}



class contact(Resource):
    def post(self, user_id):
        '''
        POST /<user_id>/convo/
        BODY:
            {'username': <contact_username>}
        RESPONSE 'data':
            {<contact_user_id>: <contact_username>}
        '''

        request_parser = reqparse.RequestParser()
        request_parser.add_argument('username', type=str, location='json')
        request_args = request_parser.parse_args()
        contact_username = request_args['username']

        database = _get_db()
        cursor = database.cursor()

        select_sql = \
                '''
                SELECT user_id FROM users WHERE username=%s
                '''

        add_contact_sql = \
                '''
                INSERT INTO contacts (user_id, contact_id, is_contact)
                    VALUES (%s, %s, %s)
                '''
        update_contact_sql = \
                '''
                UPDATE contacts
                    SET is_contact=1
                    WHERE user_id=%s and contact_id=%s
                '''

        cursor.execute(select_sql, (contact_username,))
        query = cursor.fetchone()

        # check if contact is already established
        check_contact_list = \
                '''
                SELECT is_contact FROM contacts WHERE user_id=%s and contact_id=%s
                '''

        if not query:
            data = {'error': 'The username does not exist'}
            print {'success': 0, 'data': data}
            return {'success': 0, 'data': data}
        else:
            contact_id = query[0]
            cursor.execute(check_contact_list, (user_id, contact_id,))
            query = cursor.fetchone()
            if not query:
                cursor.execute(add_contact_sql, (user_id, contact_id, 1))
                cursor.execute(add_contact_sql, (contact_id, user_id, 1))
                database.commit()
                data = {contact_id: {'contact_username': contact_username,
                                     'is_contact': 1}}
                print {'success': 1, 'data': data}
                return {'success': 1, 'data': data}
            else:
                is_contact = int(query[0])
                if not is_contact:
                    cursor.execute(update_contact_sql, (user_id, contact_id))
                    cursor.execute(update_contact_sql, (contact_id, user_id))
                    database.commit()
                    data = {contact_id: {'contact_username': contact_username,
                                         'is_contact': 1}}
                    print {'success': 1, 'data': data}
                    return {'success': 1, 'data': data}
                else:
                    data = {'error' : '%s is already on your contact list' % (contact_username)}
                    print {'success' : 0, 'data' : data}
                    return {'success' : 0, 'data' : data}


    def get(self, user_id):
        '''
        GET /<user_id>/contact/
        RESPONSE 'data':
            {'contacts':
                {<contact_id>: <contact_username>,
                 ...
                }
            }
        '''
        ret = _get_contact(user_id)
        return ret


def _get_contact(user_id):
    database = _get_db()
    cursor = database.cursor()

    select_sql = \
            '''
            SELECT contact_id,is_contact FROM contacts WHERE user_id=%s
            '''
    get_username_sql = \
            '''
            SELECT username FROM users WHERE user_id=%s
            '''

    cursor.execute(select_sql, (user_id,))
    query = cursor.fetchall()

    contacts = {}
    for contact_id, is_contact in query:
        cursor.execute(get_username_sql, (contact_id,))
        contact_username = cursor.fetchone()[0]
        contact = {int(contact_id): {'contact_username': contact_username,
                                     'is_contact': is_contact}}
        contacts.update(contact)

    data = {'contacts': contacts}
    print {'success': 1, 'data': data}
    return {'success': 1, 'data': data}

class convo(Resource):
    def get(self, user_id):
        '''
        GET /<user_id>/convo/
        RESPONSE 'data':
            {'convos':
                {<convo_id>:
                    {'convo_name': <convo_name>,
                     'members': '<member_id>,<member_id>,...'
                    }, ...
                ...
                }
            }
        '''
        ret = _get_convo(user_id)
        return ret

def _get_convo(user_id):
    database = _get_db()
    cursor = database.cursor()

    select_sql = \
            '''
            SELECT convo_id FROM users_convos WHERE user_id=%s
            '''

    cursor.execute(select_sql, (user_id,))
    query = cursor.fetchall()

    convo_name_sql = \
            '''
            SELECT convo_name FROM convos WHERE convo_id=%s
            '''
    convo_members_sql = \
            '''
            SELECT user_id FROM users_convos WHERE convo_id=%s
            '''

    convos = {}
    for convo_id, in query:
        cursor.execute(convo_name_sql, (convo_id,))
        convo_name = cursor.fetchone()[0]
        convo = {'convo_name': convo_name}
        cursor.execute(convo_members_sql, (convo_id,))
        members_list = cursor.fetchall()
        members_csv = ','.join(str(uid[0]) for uid in members_list)
        convo.update({'members': members_csv})
        convos.update({int(convo_id): convo})

    data = {'convos': convos}
    print {'success': 1, 'data': data}
    return {'success': 1, 'data': data}


class message(Resource):
    def post(self, user_id):
        '''
        POST /<user_id>/message/
        If replying to thread:
            BODY:
                {'convo_id': <convo_id>,
                 'message': <message>}
        If starting new thread:
            BODY:
                {'recipients': '<recipient_id>,<recipient_id>,...>',
                 'convo_name': <convo_name> or '',
                 'message': <message>}

        RESPONSE 'data':
            {'convo_id': <convo_id>}
        '''

        request_parser = reqparse.RequestParser()
        request_parser.add_argument('convo_id', type=str, location='json')
        request_parser.add_argument('message', type=str, location='json')
        request_parser.add_argument('recipients', type=str, location='json')
        request_parser.add_argument('convo_name', type=str, location='json')
        request_args = request_parser.parse_args()
        message = request_args['message']
        ## Existing thread
        convo_id = request_args['convo_id']
        ## New conversation
        recipients = request_args['recipients']
        convo_name = request_args['convo_name']

        database = _get_db()
        cursor = database.cursor()

        # Recipients in request when creating a new conversation.
        if recipients:
            create_convo_sql = \
                    '''
                    INSERT INTO convos (convo_name) VALUES (%s)
                        RETURNING convo_id
                    '''
            cursor.execute(create_convo_sql, (convo_name,))
            convo_id = cursor.fetchone()[0]

            user_convo_sql = \
                    '''
                    INSERT INTO users_convos (convo_id, user_id)
                        VALUES (%s, %s)
                    '''
            recipients_list = recipients.split(',')
            for recipient_id in recipients_list:
                cursor.execute(user_convo_sql, (convo_id, recipient_id))
            cursor.execute(user_convo_sql, (convo_id, user_id))
            database.commit()

        post_message_sql = \
                '''
                INSERT INTO messages (user_id, convo_id, message)
                    VALUES (%s, %s, %s)
                    RETURNING message_id
                '''

        cursor.execute(post_message_sql, (user_id, convo_id, message))
        message_id = cursor.fetchone()[0]
        database.commit()

        get_convo_members = \
                '''
                SELECT user_id FROM users_convos WHERE convo_id=%s
                '''
        insert_inbox_sql = \
                '''
                INSERT INTO users_messages (message_id, user_id)
                    VALUES (%s, %s)
                '''

        cursor.execute(get_convo_members, (convo_id,))
        query = cursor.fetchall()

        for recipient_id in query:
            if int(recipient_id) == int(user_id):
                continue
            cursor.execute(insert_inbox_sql, (message_id, recipient_id))
        database.commit()

        data = {'convo_id': convo_id}
        print {'success': 1, 'data': data}
        return {'success': 1, 'data': data}

    def get(self, user_id):
        '''
        TODO
        '''
        ret = _get_message(user_id)
        return ret


def _get_message(user_id):
    database = _get_db()
    cursor = database.cursor()

    get_messages_sql = \
            '''
            SELECT message_id FROM users_messages WHERE user_id=%s
            '''
    cursor.execute(get_messages_sql, (user_id,))
    query = cursor.fetchall()

    get_message_sql = \
            '''
            SELECT convo_id,user_id,message FROM messages WHERE message_id=%s
            '''
    # messages = { convo_id : [ convo_objs ... ]
    messages = {}
    for message_id, in query:
        cursor.execute(get_message_sql, (message_id,))
        convo_id, user_id, message = cursor.fetchone()
        if convo_id not in messages:
            messages[convo_id] = []
        message_obj = {'message': message,
                       'message_id': message_id,
                       'user_id': user_id}
        messages[convo_id].append(message_obj)

    data = {'messages': messages}
    print {'success': 1, 'data': data}
    return {'success': 1, 'data': data}


class user(Resource):
    def get(self, user_id):

        database = _get_db()
        cursor = database.cursor()

        get_user_info_sql = \
                '''
                SELECT * FROM users WHERE user_id=%s
                '''
        cursor.execute(get_user_info_sql, (user_id,))
        # user_id, username, password
        query = cursor.fetchone()

        if not query:
            data = {'error' : 'user does not exist'}
            print {'success' : 0, 'data' : data}
            return {'success' : 0, 'data' : data}
        else:
            data = {user_id : {'username' : query[1]}}
            print {'success' : 1, 'data' : data}
            return {'success' : 1, 'data' : data}

class user_all(Resource):
    def get(self):

        database = _get_db()
        cursor = database.cursor()

        get_user_all_info_sql = \
                '''
                SELECT user_id, username FROM users
                '''
        cursor.execute(get_user_all_info_sql)
        # user_id, username, password
        query = cursor.fetchall()

        if not query:
            data = {'error' : 'no users exist'}
            print {'success' : 0, 'data' : data}
            return {'success' : 0, 'data' : data}
        else:
            data = {}
            for info in query:
                data[info[0]] = {'username' : info[1]}
                print {'success' : 1, 'data' : data}
                return {'success' : 1, 'data' : data}

def _get_db():
    db_url = urlparse.urlparse(os.environ['DATABASE_URL'])
    database = psycopg2.connect(
            database=db_url.path[1:],
            user=db_url.username,
            password=db_url.password,
            host=db_url.hostname,
            port=db_url.port
        )
    return database

api.add_resource(signup, '/signup/')
api.add_resource(login, '/login/')
api.add_resource(contact, '/<int:user_id>/contact/')
api.add_resource(convo, '/<int:user_id>/convo/')
api.add_resource(message, '/<int:user_id>/message/')
api.add_resource(user, '/<int:user_id>/user/')
api.add_resource(user_all, '/user/')

if __name__ == "__main__":
    app.run(debug=True, host="127.0.0.1")

