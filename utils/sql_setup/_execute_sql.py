import os
import urlparse
import psycopg2

def _execute_sql(sql):
    '''
    Executes an arbitrary sql command.
    '''
    db_url = urlparse.urlparse(os.environ['DATABASE_URL'])
    database = psycopg2.connect(
                database=db_url.path[1:],
                user=db_url.username,
                password=db_url.password,
                host=db_url.hostname,
                port=db_url.port
            )
    cursor = database.cursor()
    cursor.execute(sql)
    database.commit()

