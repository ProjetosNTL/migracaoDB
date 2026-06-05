"""
01 - Discovery: Map entire database structure.
Extracts all schemas, tables, columns, relationships, and row counts.
Generates a complete data dictionary for ISO 27001 documentation.
"""
import sys
import csv
from datetime import datetime
from pathlib import Path

# Add project root to path (works from any directory)
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from utils.db_connection import get_connection


def get_schemas(cursor):
    """Get all schemas in the database."""
    cursor.execute("""
        SELECT s.name AS schema_name, COUNT(t.name) AS table_count
        FROM sys.schemas s
        LEFT JOIN sys.tables t ON s.schema_id = t.schema_id
        GROUP BY s.name
        HAVING COUNT(t.name) > 0
        ORDER BY s.name
    """)
    return cursor.fetchall()


def get_tables_with_rows(cursor):
    """Get all tables with row counts, ordered by size."""
    cursor.execute("""
        SELECT
            s.name AS schema_name,
            t.name AS table_name,
            SUM(p.row_count) AS row_count
        FROM sys.tables t
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        JOIN sys.dm_db_partition_stats p
            ON t.object_id = p.object_id AND p.index_id < 2
        GROUP BY s.name, t.name
        ORDER BY row_count DESC
    """)
    return cursor.fetchall()


def get_columns(cursor):
    """Get all columns with data types."""
    cursor.execute("""
        SELECT
            TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE,
            CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
        FROM INFORMATION_SCHEMA.COLUMNS
        ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION
    """)
    return cursor.fetchall()


def get_foreign_keys(cursor):
    """Get all foreign key relationships."""
    cursor.execute("""
        SELECT
            fk.name AS fk_name,
            s1.name AS from_schema,
            t1.name AS from_table,
            c1.name AS from_column,
            s2.name AS to_schema,
            t2.name AS to_table,
            c2.name AS to_column
        FROM sys.foreign_keys fk
        JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
        JOIN sys.tables t1 ON fkc.parent_object_id = t1.object_id
        JOIN sys.schemas s1 ON t1.schema_id = s1.schema_id
        JOIN sys.columns c1 ON fkc.parent_object_id = c1.object_id
            AND fkc.parent_column_id = c1.column_id
        JOIN sys.tables t2 ON fkc.referenced_object_id = t2.object_id
        JOIN sys.schemas s2 ON t2.schema_id = s2.schema_id
        JOIN sys.columns c2 ON fkc.referenced_object_id = c2.object_id
            AND fkc.referenced_column_id = c2.column_id
        ORDER BY s1.name, t1.name
    """)
    return cursor.fetchall()


def get_indexes(cursor):
    """Get all indexes (important for audit: are sensitive columns indexed?)."""
    cursor.execute("""
        SELECT
            s.name AS schema_name,
            t.name AS table_name,
            i.name AS index_name,
            i.type_desc AS index_type,
            c.name AS column_name,
            i.is_unique
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        JOIN sys.tables t ON i.object_id = t.object_id
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE i.name IS NOT NULL
        ORDER BY s.name, t.name, i.name
    """)
    return cursor.fetchall()


def main():
    conn = get_connection()
    cursor = conn.cursor()
    timestamp = datetime.now().strftime('%Y%m%d_%H%M')

    print("=" * 60)
    print("DATABASE DISCOVERY - ISO 27001 Data Inventory")
    print("=" * 60)

    # 1. Schemas
    print("\n[1/5] Mapping schemas...")
    schemas = get_schemas(cursor)
    print(f"  Found {len(schemas)} schemas with tables:")
    for s in schemas:
        print(f"    - {s[0]}: {s[1]} tables")

    # 2. Tables with row counts
    print("\n[2/5] Counting rows per table...")
    tables = get_tables_with_rows(cursor)
    print(f"  Found {len(tables)} tables total")
    print("\n  TOP 20 tables by row count:")
    for t in tables[:20]:
        print(f"    {t[0]}.{t[1]}: {t[2]:,} rows")

    # Export tables CSV
    tables_file = f'data_dictionary_tables_{timestamp}.csv'
    with open(tables_file, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f, delimiter=';')
        writer.writerow(['schema', 'tabela', 'qtd_registros', 'status_producao'])
        for t in tables:
            status = 'PRODUCAO' if t[2] > 0 else 'VAZIA'
            writer.writerow([t[0], t[1], t[2], status])
    print(f"\n  Exported: {tables_file}")

    # 3. Columns (full data dictionary)
    print("\n[3/5] Mapping all columns...")
    columns = get_columns(cursor)
    print(f"  Found {len(columns)} columns total")

    columns_file = f'data_dictionary_columns_{timestamp}.csv'
    with open(columns_file, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f, delimiter=';')
        writer.writerow(['schema', 'tabela', 'coluna', 'tipo_dado',
                         'tamanho_max', 'permite_nulo', 'valor_padrao'])
        for c in columns:
            writer.writerow(list(c))
    print(f"  Exported: {columns_file}")

    # 4. Foreign Keys (relationships)
    print("\n[4/5] Mapping foreign key relationships...")
    fks = get_foreign_keys(cursor)
    print(f"  Found {len(fks)} foreign key relationships")

    fks_file = f'data_dictionary_relationships_{timestamp}.csv'
    with open(fks_file, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f, delimiter=';')
        writer.writerow(['fk_name', 'from_schema', 'from_table', 'from_column',
                         'to_schema', 'to_table', 'to_column'])
        for fk in fks:
            writer.writerow(list(fk))
    print(f"  Exported: {fks_file}")

    # 5. Indexes
    print("\n[5/5] Mapping indexes...")
    indexes = get_indexes(cursor)
    print(f"  Found {len(indexes)} indexed columns")

    # Summary
    production_tables = [t for t in tables if t[2] > 0]
    empty_tables = [t for t in tables if t[2] == 0]

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"  Schemas:           {len(schemas)}")
    print(f"  Total tables:      {len(tables)}")
    print(f"  Production tables: {len(production_tables)} (with data)")
    print(f"  Empty tables:      {len(empty_tables)} (candidates for removal)")
    print(f"  Total columns:     {len(columns)}")
    print(f"  Foreign keys:      {len(fks)}")
    print(f"  Indexes:           {len(indexes)}")
    print(f"\n  Files generated in current directory.")

    conn.close()


if __name__ == '__main__':
    main()
