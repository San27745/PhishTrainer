import mysql.connector
from mysql.connector import Error
from flask import current_app

def get_db_connection():
    return mysql.connector.connect(
        host=current_app.config["DB_HOST"],
        port=current_app.config["DB_PORT"],
        user=current_app.config["DB_USER"],
        password=current_app.config["DB_PASSWORD"],
        database=current_app.config["DB_NAME"],
        connection_timeout=5,
    )

def test_db_connection():
    connection = None
    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT DATABASE(), VERSION()")
        row = cursor.fetchone()
        cursor.close()
        return {"ok": True, "database": row[0], "server_version": row[1]}
    except Error as exc:
        return {"ok": False, "error": str(exc)}
    finally:
        if connection and connection.is_connected():
            connection.close()
