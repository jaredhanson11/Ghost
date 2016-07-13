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


def _drop_users_messages():
    '''
    Drop the table users_messages.
    '''

    sql = \
        '''
        DROP TABLE users_messages;
        '''
    _execute_sql(sql)
    print 'Dropped table: users_messages'

if __name__ == '__main__':
    while True:
        create_or_drop = raw_input('create or drop?\n')
        if create_or_drop.lower() == 'create':
            _create_users_messages()
            break
        if create_or_drop.lower() == 'drop':
            _drop_users_messages()
            break
        else:
            print 'The input was invalid.'

