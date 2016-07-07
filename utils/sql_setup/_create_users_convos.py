from _execute_sql import _execute_sql

def _create_users_convos():
    '''
    Initialize the table 'users-convos' in your database.
    '''

    sql = '''
        CREATE TABLE users_convos (
            convo_id INT NOT NULL,
            user_id INT NOT NULL
        )'''
    _execute_sql(sql)
    print 'Created table: users-convos (convo_id, user_id)'

if __name__ == '__main__':
    _create_users_convos()
