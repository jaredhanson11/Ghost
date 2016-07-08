from _execute_sql import _execute_sql

def _create_users():
    '''
    Initialize the table 'users' in your database.
    '''

    sql = '''
        CREATE TABLE users (
            user_id serial PRIMARY KEY,
            username varchar(20) NOT NULL,
            password varchar(30) NOT NULL
        )'''
    _execute_sql(sql)
    print 'Created table: users (user_id, username, password)'

def _drop_users():
    '''
    Drop the table users.
    '''

    sql = \
        '''
        DROP TABLE users;
        '''
    _execute_sql(sql)
    print 'Dropped table: users'

if __name__ == '__main__':
    while True:
        create_or_drop = raw_input('create or drop?\n')
        if create_or_drop.lower() == 'create':
            _create_users()
            break
        if create_or_drop.lower() == 'drop':
            _drop_users()
            break
        else:
            print 'The input was invalid.'

