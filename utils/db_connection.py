"""Shared database connection module."""
import pyodbc
from dotenv import load_dotenv
import os

load_dotenv()


def get_connection():
    """Return a pyodbc connection to the SQL Server database."""
    return pyodbc.connect(
        f"DRIVER={{SQL Server}};"
        f"SERVER={os.getenv('DB_SERVER')};DATABASE={os.getenv('DB_NAME')};"
        f"UID={os.getenv('DB_USER')};PWD={os.getenv('DB_PASSWORD')}"
    )
