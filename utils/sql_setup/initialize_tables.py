from _create_contacts import _create_contacts
from _create_convos import _create_convos
from _create_messages import _create_messages
from _create_users import _create_users
from _create_users_convos import _create_users_convos
from _create_users_messages import _create_users_messages

def initialize_tables():
    '''
    Sets up all the neccesary tables for Ghost.
    '''
    _create_contacts()
    _create_convos()
    _create_messages()
    _create_users()
    _create_users_convos()
    _create_users_messages()

if __name__ == '__main__':
    initialize_tables()
