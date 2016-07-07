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

if __name__ == '__main__':
    _create_messages()
