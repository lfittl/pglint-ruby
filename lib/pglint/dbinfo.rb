module Pglint
  class Dbinfo
    def self.schema
      schema = {}
      columns.each do |c|
        t = [c['schema'], c['table']].join('.')
        schema[t] ||= {}
        schema[t]['schema_name'] = c.delete('schema')
        schema[t]['table_name'] = c.delete('table')
        schema[t]['size_bytes'] = c.delete('tablesize')
        schema[t]['columns'] ||= []
        schema[t]['columns'] << c
      end
      indices.each do |i|
        t = [i['schema'], i['table']].join('.')
        schema[t]['indices'] ||= []
        schema[t]['indices'] << i
      end
      schema
    end
    
    def self.columns
      ActiveRecord::Base.connection.select_all("SELECT n.nspname AS schema,
       c.relname AS table,
       pg_catalog.pg_table_size(c.oid) AS tablesize,
       a.attname AS name,
       pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
  (SELECT pg_catalog.pg_get_expr(d.adbin, d.adrelid)
   FROM pg_catalog.pg_attrdef d
   WHERE d.adrelid = a.attrelid
     AND d.adnum = a.attnum
     AND a.atthasdef) AS default_value,
       a.attnotnull AS not_null,
       a.attnum AS position
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid
WHERE c.relkind = 'r'
  AND n.nspname <> 'pg_catalog'
  AND n.nspname <> 'information_schema'
  AND n.nspname !~ '^pg_toast'
  AND a.attnum > 0
  AND NOT a.attisdropped
ORDER BY n.nspname,
         c.relname,
         a.attnum")
    end
    
    def self.indices
      ActiveRecord::Base.connection.select_all("SELECT n.nspname AS schema,
       c.relname AS table,
       i.indkey::text AS columns,
       c2.relname AS name,
       pg_relation_size(c2.oid) AS size_bytes,
       i.indisprimary AS is_primary,
       i.indisunique AS is_unique,
       i.indisvalid AS is_valid,
       pg_catalog.pg_get_indexdef(i.indexrelid, 0, TRUE) AS index_def,
       pg_catalog.pg_get_constraintdef(con.oid, TRUE) AS constraint_def
FROM pg_catalog.pg_class c,
     pg_catalog.pg_class c2,
     pg_catalog.pg_namespace n,
     pg_catalog.pg_index i
LEFT JOIN pg_catalog.pg_constraint con ON (conrelid = i.indrelid
                                           AND conindid = i.indexrelid
                                           AND contype IN ('p', 'u', 'x'))
WHERE c.relkind = 'r'
  AND n.nspname <> 'pg_catalog'
  AND n.nspname <> 'information_schema'
  AND n.nspname !~ '^pg_toast'
  AND c.oid = i.indrelid
  AND i.indexrelid = c2.oid
  AND n.oid = c.relnamespace
ORDER BY n.nspname,
         c.relname,
         i.indisprimary DESC,
         i.indisunique DESC,
         c2.relname")
    end
  end
end