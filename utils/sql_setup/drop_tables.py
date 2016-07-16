from _contacts import _drop_contacts
from _convos import _drop_convos
from _messages import _drop_messages
from _users import _drop_users
from _users_convos import _drop_users_convos
from _users_messages import _drop_users_messages

def drop_tables():
    '''
    Sets up all the neccesary tables for Ghost.
    '''

    functions = [_drop_contacts, _drop_convos, _drop_messages,
            _drop_users, _drop_users_convos, _drop_users_messages]


    for function in functions:
        try:
            function()
        except:
            print 'There was an error running %s()' % function
            continue

if __name__ == '__main__':
    drop_tables()
