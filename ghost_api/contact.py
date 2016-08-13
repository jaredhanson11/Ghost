from flask_restful import Resource, reqparse
from db_init import _get_db

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
            #print {'success': 0, 'data': data}
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
                #print {'success': 1, 'data': data}
                return {'success': 1, 'data': data}
            else:
                is_contact = int(query[0])
                if not is_contact:
                    cursor.execute(update_contact_sql, (user_id, contact_id))
                    cursor.execute(update_contact_sql, (contact_id, user_id))
                    database.commit()
                    data = {contact_id: {'contact_username': contact_username,
                                         'is_contact': 1}}
                    #print {'success': 1, 'data': data}
                    return {'success': 1, 'data': data}
                else:
                    data = {'error' : '%s is already on your contact list' % (contact_username)}
                    #print {'success' : 0, 'data' : data}
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

# main page methods
def _get_contact(user_id,contact_ids_to_delete):
    database = _get_db()
    cursor = database.cursor()

    if len(contact_ids_to_delete) != 0:
        contact_ids_to_delete_str = tuple(contact_ids_to_delete.split(','))
        select_sql = \
                '''
                SELECT contact_id,is_contact FROM contacts WHERE user_id=%s AND contact_id NOT IN %s
                '''
        cursor.execute(select_sql, (user_id,contact_ids_to_delete_str))
    else:
        select_sql = \
                '''
                SELECT contact_id,is_contact FROM contacts WHERE user_id=%s
                '''
        cursor.execute(select_sql, (user_id,))

    get_username_sql = \
            '''
            SELECT username FROM users WHERE user_id=%s
            '''
    query = cursor.fetchall()

    contacts = {}
    for contact_id, is_contact in query:
        cursor.execute(get_username_sql, (contact_id,))
        contact_username = cursor.fetchone()[0]
        contact = {int(contact_id): {'contact_username': contact_username,
                                     'is_contact': is_contact}}
        contacts.update(contact)

    if len(contact_ids_to_delete) != 0:
        contact_ids_deleted = delete_contacts(user_id,contact_ids_to_delete)
    else:
        contact_ids_deleted = ''

    data = {'contacts': contacts, 'deleted': contact_ids_deleted}
    #print {'success': 1, 'data': data}
    return {'success': 1, 'data': data}

def delete_contacts(user_id,contact_ids_to_delete):
    database = _get_db()
    cursor = database.cursor()

    delete_inbox_sql = \
            '''
            DELETE FROM contacts WHERE user_id=%s AND contact_id=%s
            '''

    contact_ids_list = contact_ids_to_delete.split(',')
    contact_ids_set = set(contact_ids_list)

    deleted_ids_list = []
    for contact_id in contact_ids_set:
        cursor.execute(delete_inbox_sql, (user_id, contact_id))

        if int(cursor.rowcount):
            deleted_ids_list.append(contact_id)

    database.commit()

    contact_ids = ','.join(deleted_ids_list)
    return contact_ids