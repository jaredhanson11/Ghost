from flask_restful import Resource, reqparse
from db_init import _get_db
from contact import _get_contact
from convo import _get_convo
from message import _get_message

class main_page(Resource):
    def get(self, user_id):
        contacts = _get_contact(user_id)['data']['contacts']
        convos = _get_convo(user_id)['data']['convos']
        messages = _get_message(user_id)['data']['messages']

        user_interactions = set()

        for convo in convos.values():
            members_list = convo['members'].split(',')
            for member_id in members_list:
                if int(member_id) not in contacts:
                    if int(member_id) == int(user_id):
                        continue
                    known_user = _add_known_user(user_id, member_id)
                    contacts.update(known_user)

        data = {}
        data.update({'contacts': contacts})
        data.update({'convos': convos})
        data.update({'messages': messages})
        ret = {'success': 1, 'data': data}
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
