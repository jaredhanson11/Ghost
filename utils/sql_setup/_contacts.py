from _execute_sql import _execute_sql

def _create_contacts():
    '''
    Initialize the table 'contacts' in your database.
    '''

    sql = \
        '''
        CREATE TABLE contacts (
            user_id INT NOT NULL,
            contact_id INT NOT NULL,
            is_contact INT NOT NULL)
        '''
    _execute_sql(sql)
    print 'Created table: contacts (user_id, contact_id)'

def _drop_contacts():
    '''
    Drop the table contacts.
    '''

    sql = \
        '''
        DROP TABLE contacts;
        '''
    _execute_sql(sql)
    print 'Dropped table: contacts'

if __name__ == '__main__':
    while True:
        create_or_drop = raw_input('create or drop?\n')
        if create_or_drop.lower() == 'create':
            _create_contacts()
            break
        if create_or_drop.lower() == 'drop':
            _drop_contacts()
            break
        else:
            print 'The input was invalid.'

