from _execute_sql import _execute_sql

def _create_convos():
    '''
    Initialize the table 'convos' in your database.
    '''

    sql = '''
        CREATE TABLE convos (
            convo_id serial PRIMARY KEY,
            convo_name VARCHAR(40)
        )'''
    _execute_sql(sql)
    print 'Created table: convos (convo_id, convo_name)'

if __name__ == '__main__':
    _create_convos()
