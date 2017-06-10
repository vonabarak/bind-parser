
**bind-parser**

A python library (zone_parser) and a script (zone_insert)
 to parse ISC named zone-files and import into PostgreSQL
 database which can be used by named daemon to provide
 database-derived DNS service

zone_parser.py requires python3 to work
zone_insert.py requires zone_parser and psycopg2

Project does not aims high performance or scalability on
 large data sets (untested but probably it will be slower than
 plain zone-file backended named).
Instead of that it aims type safety and consistency for
 database as a named backend. It should be impossible to
 insert some data into database that cannot be understood by
 named.

**known bugs**
Library does not support $INCLUDE directive of zone-file
