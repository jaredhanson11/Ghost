from _execute_sql import _execute_sql

def _create_contacts():
    '''
    Initialize the table 'contacts' in your database.
    '''

    sql = ''' \
        CREATE TABLE contacts (
            user_id INT NOT NULL,
            contact_id INT NOT NULL
        )'''
    _execute_sql(sql)
    print 'Created table: contacts (user_id, contact_id)'

if __name__ == '__main__':
    _create_contacts()

