from _execute_sql import _execute_sql

def _create_users_messages():
    '''
    Initialize the table 'messages' in your database.
    '''

    sql = ''' \
        CREATE TABLE users_messages (
            message_id INT NOT NULL,
            user_id INT NOT NULL
        )'''
    _execute_sql(sql)
    print 'Created table: users-messages (message_id, user_id)'


if __name__ == '__main__':
    _create_users_messages()
