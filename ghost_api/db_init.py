import os
import psycopg2
import urlparse

def _get_db():
    db_url = urlparse.urlparse(os.environ['DATABASE_URL'])
    database = psycopg2.connect(
            database=db_url.path[1:],
            user=db_url.username,
            password=db_url.password,
            host=db_url.hostname,
            port=db_url.port
        )
    return database
