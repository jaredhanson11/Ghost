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

if __name__ == '__main__':
    _create_users()
