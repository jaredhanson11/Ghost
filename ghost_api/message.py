from flask_restful import Resource, reqparse
from db_init import _get_db

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

        for recipient_id, in query:
            if int(recipient_id) == int(user_id):
                continue
            cursor.execute(insert_inbox_sql, (message_id, recipient_id))
        database.commit()

        data = {'convo_id': convo_id}
        #print {'success': 1, 'data': data}
        return {'success': 1, 'data': data}

    def put(self, user_id):
        '''
        PUT /user_id/message/
        BODY
            {'message_ids': '<message_id>,<message_id>,...'}
        RESPONSE 'data'
            {'message_ids': '<message_id>,<message_id>,...'}

        Send a csv of message_ids that have been read
        Returns a csv of message_ids that were successfully removed from inbox.
        '''
        request_parser = reqparse.RequestParser()
        request_parser.add_argument('message_ids', type=str, location='json')
        request_args = request_parser.parse_args()
        message_ids_csv = request_args['message_ids']

        database = _get_db()
        cursor = database.cursor()

        delete_inbox_sql = \
                '''
                DELETE FROM users_messages WHERE user_id=%s AND message_id=%s
                '''

        message_ids_list = message_ids_csv.split(',')
        message_ids_set = set(message_ids_list)

        deleted_ids_list = []
        for message_id in message_ids_set:
            cursor.execute(delete_inbox_sql, (user_id, message_id))

            if int(cursor.rowcount):
                deleted_ids_list.append(message_id)

        database.commit()

        data = {'message_ids': ','.join(deleted_ids_list)}

        #print {'success': 1, 'data': data}
        return {'success': 1, 'data': data}

    def get(self, user_id):
        '''
        TODO
        '''
        ret = _get_message(user_id)
        return ret

# main page methods
def _get_message(user_id, message_ids_to_delete):
    database = _get_db()
    cursor = database.cursor()
    
    # omits all messages that are to be deleted
    if len(message_ids_to_delete) != 0:
        message_ids_to_delete_str = tuple(message_ids_to_delete.split(','))
        get_messages_sql = \
                '''
                SELECT message_id FROM users_messages WHERE user_id=%s AND message_id NOT IN %s
                '''
        cursor.execute(get_messages_sql, (user_id,message_ids_to_delete_str))
    else:
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

    # perform deletion of any message_ids
    # todo: how can we perform this operation in background so we return data right away on main thread?
    if len(message_ids_to_delete) != 0:
        message_ids_deleted = delete_messages(user_id,message_ids_to_delete)
    else:
        message_ids_deleted = ''

    data = {'messages': messages, 'deleted' : message_ids_deleted}
    #print {'success': 1, 'data': data}
    return {'success': 1, 'data': data}

def delete_messages(user_id,message_ids_to_delete):
    database = _get_db()
    cursor = database.cursor()

    delete_inbox_sql = \
            '''
            DELETE FROM users_messages WHERE user_id=%s AND message_id=%s
            '''

    message_ids_list = message_ids_to_delete.split(',')
    message_ids_set = set(message_ids_list)

    deleted_ids_list = []
    for message_id in message_ids_set:
        cursor.execute(delete_inbox_sql, (user_id, message_id))

        if int(cursor.rowcount):
            deleted_ids_list.append(message_id)

    database.commit()

    message_ids = ','.join(deleted_ids_list)
    return message_ids