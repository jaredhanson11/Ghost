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

# main page methods
def _get_convo(user_id, convo_ids_to_delete):
    database = _get_db()
    cursor = database.cursor()
    if len(convo_ids_to_delete) != 0:
        convo_ids_to_delete_str = tuple(convo_ids_to_delete.split(','))
        select_sql = \
                '''
                SELECT convo_id FROM users_convos WHERE user_id=%s AND convo_id NOT IN %s
                '''
        cursor.execute(select_sql, (user_id,convo_ids_to_delete_str))
    else:
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
        convos.update({convo_id: convo})

    if len(convo_ids_to_delete) != 0:
        convo_ids_deleted = delete_convos(user_id, convo_ids_to_delete)
    else:
        convo_ids_deleted = ''

    data = {'convos': convos, 'deleted': convo_ids_deleted}
    #print {'success': 1, 'data': data}
    return {'success': 1, 'data': data}

def delete_convos(user_id,convo_ids_to_delete):
    database = _get_db()
    cursor = database.cursor()

    delete_inbox_sql = \
            '''
            DELETE FROM users_convos WHERE user_id=%s AND convo_id=%s
            '''

    convo_ids_list = convo_ids_to_delete.split(',')
    convo_ids_set = set(convo_ids_list)

    deleted_ids_list = []
    for convo_id in convo_ids_set:
        cursor.execute(delete_inbox_sql, (user_id, convo_id))

        if int(cursor.rowcount):
            deleted_ids_list.append(convo_id)

    database.commit()

    convo_ids = ','.join(deleted_ids_list)
    return convo_ids