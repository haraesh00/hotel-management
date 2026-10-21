# PostgreSQL connection manager for GrandStay.
import os
from contextlib import contextmanager
from urllib.parse import urlparse
import psycopg2
from psycopg2.extras import RealDictCursor
from config import Config

def get_raw_connection(include_db=True):
    """Connect using Render DATABASE_URL or PG* environment variables."""
    if Config.DATABASE_URL:
        url = Config.DATABASE_URL
        # Render internal URLs may use postgres://; psycopg2 accepts postgres://, too.
        conn = psycopg2.connect(url, cursor_factory=RealDictCursor, connect_timeout=10, sslmode=os.getenv("PGSSLMODE", "prefer"))
    else:
        conn = psycopg2.connect(
            host=Config.PGHOST, port=Config.PGPORT, user=Config.PGUSER,
            password=Config.PGPASSWORD, dbname=Config.PGDATABASE,
            cursor_factory=RealDictCursor, connect_timeout=5,
            sslmode=os.getenv("PGSSLMODE", "prefer")
        )
    return conn

@contextmanager
def get_db():
    conn = None
    try:
        conn = get_raw_connection()
        yield conn
        conn.commit()
    except Exception:
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            conn.close()

def test_connection():
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT 1 AS test_val")
                res = cursor.fetchone()
        return (True, "Connected to PostgreSQL successfully.") if res and res.get('test_val') == 1 else (False, "Unexpected database test result.")
    except Exception as e:
        return False, f"PostgreSQL connection failed: {e}"

def query_all(sql, params=None):
    with get_db() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql, params or ())
            return cursor.fetchall()

def query_one(sql, params=None):
    with get_db() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql, params or ())
            return cursor.fetchone()

def execute(sql, params=None):
    """Execute write SQL. INSERT statements return the generated id where available."""
    with get_db() as conn:
        with conn.cursor() as cursor:
            statement = sql.strip().rstrip(';')
            if statement.lstrip().upper().startswith("INSERT INTO") and " RETURNING " not in statement.upper():
                statement += " RETURNING id"
                cursor.execute(statement, params or ())
                row = cursor.fetchone()
                return (row.get('id') if row else None), cursor.rowcount
            cursor.execute(statement, params or ())
            return None, cursor.rowcount

def init_db(schema_path=None):
    """Create tables in the already-created PostgreSQL database; no demo data."""
    if schema_path is None:
        schema_path = os.path.join(os.path.dirname(__file__), 'schema.sql')
    if not os.path.exists(schema_path):
        return False, f"Schema file not found at {schema_path}"
    try:
        with open(schema_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
        statements = [stmt.strip() for stmt in sql_script.split(';') if stmt.strip()]
        with get_db() as conn:
            with conn.cursor() as cursor:
                for stmt in statements:
                    clean_stmt = "\n".join(line for line in stmt.splitlines() if not line.strip().startswith('--'))
                    if clean_stmt.strip():
                        cursor.execute(clean_stmt)
        return True, "PostgreSQL schema initialized successfully. No sample records were inserted."
    except Exception as e:
        return False, f"Failed to initialize PostgreSQL schema: {e}"
