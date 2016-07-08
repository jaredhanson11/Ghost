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


def _drop_convos():
    '''
    Drop the table convos.
    '''

    sql = \
        '''
        DROP TABLE convos;
        '''
    _execute_sql(sql)
    print 'Dropped table: convos'

if __name__ == '__main__':
    while True:
        create_or_drop = raw_input('create or drop?\n')
        if create_or_drop.lower() == 'create':
            _create_convos()
            break
        if create_or_drop.lower() == 'drop':
            _drop_convos()
            break
        else:
            print 'The input was invalid.'

