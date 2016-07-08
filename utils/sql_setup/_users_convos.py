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

def _drop_users_convos():
    '''
    Drop the table users_convos.
    '''

    sql = \
        '''
        DROP TABLE users_convos;
        '''
    _execute_sql(sql)
    print 'Dropped table: users_convos'

if __name__ == '__main__':
    while True:
        create_or_drop = raw_input('create or drop?\n')
        if create_or_drop.lower() == 'create':
            _create_users_convos()
            break
        if create_or_drop.lower() == 'drop':
            _drop_users_convos()
            break
        else:
            print 'The input was invalid.'

