from _contacts import _create_contacts
from _convos import _create_convos
from _messages import _create_messages
from _users import _create_users
from _users_convos import _create_users_convos
from _users_messages import _create_users_messages

def initialize_tables():
    '''
    Sets up all the neccesary tables for Ghost.
    '''
    functions = [_create_contacts, _create_convos, _create_messages,
            _create_users, _create_users_convos, _create_users_messages]

    for function in functions:
        try:
            function()
        except:
            print 'There was an error running %s()' % function
            continue
if __name__ == '__main__':
    initialize_tables()
