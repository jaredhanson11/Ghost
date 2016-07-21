from flask_restful import Resource, reqparse
from db_init import _get_db

class signup(Resource):
    def post(self):
        '''
        POST /signup/
        BODY:
            {'username': <username>,
             'password': <password>}
        RESPONSE 'data':
            {'user_id': <user_id>,
             'username': <username>}
        '''

        request_parser = reqparse.RequestParser()
        request_parser.add_argument('username', type=str, location='json')
        request_parser.add_argument('password', type=str, location='json')
        request_args = request_parser.parse_args()
        username = request_args['username']
        password = request_args['password']

        print username, password
        database = _get_db()
        cursor = database.cursor()

        select_sql = \
                '''
                SELECT user_id FROM users WHERE username=%s
                '''
        insert_sql = \
                '''
                INSERT INTO users (username, password) VALUES (%s,%s)
                    RETURNING user_id
                '''

        cursor.execute(select_sql, (username,))
        query = cursor.fetchall()

        if not query:

            cursor.execute(insert_sql, (username, password))
            user_id = cursor.fetchone()[0]
            database.commit()
            data = {'user_id': user_id, 'username': username}
            print {'success': 1, 'data': data}
            return {'success': 1, 'data': data}
        else:
            data = {'error': 'The username is already in use.'}
            print {'success': 0, 'data': data}
            return {'success': 0, 'data': data}

class login(Resource):
    def post(self):
        '''
        POST /login/
        BODY:
            {'username': <username>,
             'password': <password>}
        RESPONSE 'data':
            {'user_id': <user_id>,
             'username': <username>}
        '''

        request_parser = reqparse.RequestParser()
        request_parser.add_argument('username', type=str, location='json')
        request_parser.add_argument('password', type=str, location='json')
        request_args = request_parser.parse_args()
        username = request_args['username']
        password = request_args['password']

        database = _get_db()
        cursor = database.cursor()

        select_sql = \
                '''
                SELECT user_id FROM users WHERE username=%s and password=%s
                '''

        cursor.execute(select_sql, (username, password))
        query = cursor.fetchone()

        if not query:
            data = {'error': 'The username/password combo is invalid.'}
            print {'success': 0, 'data': data}
            return {'success': 0, 'data': data}
        else:
            user_id = query[0]
            data = {'user_id': user_id, 'username': username}
            print {'success': 1, 'data': data}
            return {'success': 1, 'data': data}
