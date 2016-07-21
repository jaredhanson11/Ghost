from flask import Flask, render_template, jsonify
from flask_restful import Resource, Api, reqparse

# Import Resources
from ghost_api.auth import signup, login
from ghost_api.main_page import main_page
from ghost_api.contact import contact
from ghost_api.convo import convo
from ghost_api.message import message

app = Flask(__name__)
api = Api(app)

api.add_resource(signup, '/signup/')
api.add_resource(login, '/login/')
api.add_resource(main_page, '/<int:user_id>/main_page/')
api.add_resource(contact, '/<int:user_id>/contact/')
api.add_resource(convo, '/<int:user_id>/convo/')
api.add_resource(message, '/<int:user_id>/message/')

## Saved for use later if needed.
class user(Resource):
    def get(self, user_id):

        database = _get_db()
        cursor = database.cursor()

        get_user_info_sql = \
                '''
                SELECT * FROM users WHERE user_id=%s
                '''
        cursor.execute(get_user_info_sql, (user_id,))
        # user_id, username, password
        query = cursor.fetchone()

        if not query:
            data = {'error' : 'user does not exist'}
            print {'success' : 0, 'data' : data}
            return {'success' : 0, 'data' : data}
        else:
            data = {user_id : {'username' : query[1]}}
            print {'success' : 1, 'data' : data}
            return {'success' : 1, 'data' : data}

class user_all(Resource):
    def get(self):

        database = _get_db()
        cursor = database.cursor()

        get_user_all_info_sql = \
                '''
                SELECT user_id, username FROM users
                '''
        cursor.execute(get_user_all_info_sql)
        # user_id, username, password
        query = cursor.fetchall()

        if not query:
            data = {'error' : 'no users exist'}
            print {'success' : 0, 'data' : data}
            return {'success' : 0, 'data' : data}
        else:
            data = {}
            for info in query:
                data[info[0]] = {'username' : info[1]}
                print {'success' : 1, 'data' : data}
                return {'success' : 1, 'data' : data}

api.add_resource(user, '/<int:user_id>/user/')
api.add_resource(user_all, '/user/')

if __name__ == "__main__":
    app.run(debug=True, host="127.0.0.1")

