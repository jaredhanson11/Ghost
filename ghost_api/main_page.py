from flask_restful import Resource, reqparse
from db_init import _get_db
from contact import _get_contact
from convo import _get_convo
from message import _get_message

class main_page(Resource):
    def post(self, user_id):
        '''
        POST /<user_id>/main_page/
        BODY:
            {'msg_ids_to_delete': '<msg_id>,<msg_id>,...'}
        RESPONSE 'data':
            {<contact_user_id>: <contact_username>}
        '''

        request_parser = reqparse.RequestParser()
        request_parser.add_argument('message_ids_to_delete', type=str, location='json')
        request_parser.add_argument('convo_ids_to_delete', type=str, location='json')
        request_parser.add_argument('contact_ids_to_delete', type=str, location='json')
        request_args = request_parser.parse_args()
        message_ids_to_delete = request_args['message_ids_to_delete']
        convo_ids_to_delete = request_args['convo_ids_to_delete']
        contact_ids_to_delete = request_args['contact_ids_to_delete']

        message_data = _get_message(user_id, message_ids_to_delete)['data']
        messages = message_data['messages']
        messages_deleted = message_data['deleted']

        convo_data = _get_convo(user_id, convo_ids_to_delete)['data']
        convos = convo_data['convos']
        convos_deleted = convo_data['deleted']

        contact_data = _get_contact(user_id, contact_ids_to_delete)['data']
        contacts = contact_data['contacts']
        contacts_deleted = contact_data['deleted']

        user_interactions = set()

        # adding users in conversations, but not in contacts list, as contacts (is_contact=0)
        for convo in convos.values():
            members_list = convo['members'].split(',')
            for member_id in members_list:
                if int(member_id) not in contacts:
                    if int(member_id) == int(user_id):
                        continue
                    known_user = _add_known_user(user_id, member_id)
                    contacts.update(known_user)

        data = {}
        data.update({'messages': messages})
        data.update({'messages_deleted': messages_deleted})
        data.update({'convos': convos})
        data.update({'convos_deleted': convos_deleted})
        data.update({'contacts': contacts})
        data.update({'contacts_deleted': contacts_deleted})
        ret = {'success': data}
        print ret
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

    return {known_user_id: {'contact_username': known_user_name,
                                 'is_contact': 0}}
