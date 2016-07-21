from flask_restful import Resource, reqparse
from db_init import _get_db

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
