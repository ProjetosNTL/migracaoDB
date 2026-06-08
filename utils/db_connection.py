"""Shared database connection module. Supports SQL Server (source) and MySQL (target)."""
import pyodbc
from dotenv import load_dotenv
import os

load_dotenv()


def get_connection(target='sqlserver'):
    """Return a database connection.

    Args:
        target: 'sqlserver' (source/legacy) or 'mysql' (new ISO database)
    """
    if target == 'sqlserver':
        return pyodbc.connect(
            f"DRIVER={{SQL Server}};"
            f"SERVER={os.getenv('DB_SERVER')};DATABASE={os.getenv('DB_NAME')};"
            f"UID={os.getenv('DB_USER')};PWD={os.getenv('DB_PASSWORD')}"
        )
    elif target == 'mysql':
        try:
            import mysql.connector
            return mysql.connector.connect(
                host=os.getenv('MYSQL_HOST', 'localhost'),
                port=int(os.getenv('MYSQL_PORT', '3306')),
                user=os.getenv('MYSQL_USER', 'root'),
                password=os.getenv('MYSQL_PASSWORD', ''),
                database=os.getenv('MYSQL_DATABASE', 'neeo_ntl_iso'),
                charset='utf8mb4'
            )
        except ImportError:
            raise ImportError("mysql-connector-python not installed. Run: pip install mysql-connector-python")
    else:
        raise ValueError(f"Unknown target: {target}. Use 'sqlserver' or 'mysql'")
