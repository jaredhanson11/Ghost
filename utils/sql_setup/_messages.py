from _execute_sql import _execute_sql

def _create_messages():
    '''
    Initialize the table 'messages' in your database.
    '''

    sql = ''' \
        CREATE TABLE messages (
            message_id serial PRIMARY KEY,
            convo_id INT NOT NULL,
            user_id INT NOT NULL,
            message VARCHAR(300) NOT NULL
        )'''
    _execute_sql(sql)
    print 'Created table: messages (message_id, convo_id, user_id, message)'

def _drop_messages():
    '''
    Drop the table messages.
    '''

    sql = \
        '''
        DROP TABLE messages;
        '''
    _execute_sql(sql)
    print 'Dropped table: messages'


if __name__ == '__main__':
    while True:
        create_or_drop = raw_input('create or drop?\n')
        if create_or_drop.lower() == 'create':
            _create_messages()
            break
        if create_or_drop.lower() == 'drop':
            _drop_messages()
            break
        else:
            print 'The input was invalid.'

