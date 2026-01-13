import parametros
import psycopg

def get_db():
    return psycopg.connect(
            host=parametros.host,
            dbname=parametros.dbname,
            user=parametros.user,
            password=parametros.password
        )