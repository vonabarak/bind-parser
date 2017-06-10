#!/usr/bin/env python3
"""
Script for reading zone-file and inserting it's data
into PostgreSQL database or exporting as sql file
"""

from zone_parser import read_file
import psycopg2
import sys

# set this variable to some string for output to be written to that file
# as an SQL statements (like pg_dump output)
# or set it to False or None to use database as output destination
OUT_TO_FILE = False
# OUT_TO_FILE = 'zone_insert.sql'

DBNAME = 'bind'
DBUSER = 'postgres'
DBHOST = '/run/postgresql'
DBPASS = '***************'


class Cur:
    """
    Class simulating sql-driver's cursor class but just writing out all data into file instead of database
    """
    @staticmethod
    def execute(a, b):
        """
        :rtype: object
        """
        with open(OUT_TO_FILE, 'a+') as file:

            file.write(a % tuple(["'" + str(x) + "'" for x in b]))
            file.write('\n')


def insert_records(list_of_tuples, zone=None):

    if not OUT_TO_FILE:
        conn = psycopg2.connect(dbname=DBNAME, user=DBUSER, password=DBPASS)
        cur = conn.cursor()
    else:
        conn = None
        cur = Cur()

    for record in list_of_tuples:
        if record[2] == 'SOA':
            if zone is None:
                print(record)
                if record[0] is not None and record[0].strip() != '@':
                    zone = record[0]
                else:
                    print('Zone undefined!\n')
                    return None
            if zone[-1] == '.':
                zone = zone[:-1]
            print('SOA record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into soa
            (zone, ttl, mname, rname, serial, refresh, retry, expire, minimum) values
            (%s, %s, %s, %s, %s, %s, %s, %s, %s);''',
                        (zone, record[1], record[3][0], record[3][1], record[3][2],
                         record[3][3], record[3][4], record[3][5], record[3][6]))

        elif record[2] == 'NS':
            print('NS record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into ns
            (zone, ttl, host, nsdname) values
            (%s, %s, %s, %s);''', (zone, record[1], record[0], record[3][0]))

        elif record[2] == 'MX':
            print('MX record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into mx
            (zone, ttl, host, preference, exchange) values
            (%s, %s, %s, %s, %s);''', (zone, record[1], record[0], record[3][0], record[3][1]))

        elif record[2] == 'A':
            print('A record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into a
            (zone, ttl, host, address) values
            (%s, %s, %s, %s);''', (zone, record[1], record[0], record[3][0]))

        elif record[2] == 'AAAA':
            print('AAAA record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into aaaa
            (zone, ttl, host, address) values
            (%s, %s, %s, %s);''', (zone, record[1], record[0], record[3][0]))

        elif record[2] == 'CNAME':
            print('CNAME record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into cname
            (zone, ttl, host, cname) values
            (%s, %s, %s, %s);''', (zone, record[1], record[0], record[3][0]))

        elif record[2] == 'TXT':
            print('TXT record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into txt
            (zone, ttl, host, txt_data) values
            (%s, %s, %s, %s);''', (zone, record[1], record[0], record[3][0]))

        elif record[2] == 'SPF':
            print('SPF record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into spf
            (zone, ttl, host, txt_data) values
            (%s, %s, %s, %s);''', (zone, record[1], record[0], record[3][0]))

        elif record[2] == 'SRV':
            print('SRV record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into srv
            (zone, ttl, host, priority, weight, port, target) values
            (%s, %s, %s, %s, %s, %s, %s);''',
                        (zone, record[1], record[0], record[3][0], record[3][1], record[3][2], record[3][3]))

        elif record[2] == 'HINFO':
            print('HINFO record:\n\thost = %s\n\tttl = %s\n\tdata = %s\n' % (record[0], record[1], record[3]))
            cur.execute('''insert into hinfo
            (zone, ttl, host, cpu ,os) values
            (%s, %s, %s, %s, %s, %s);''', (zone, record[1], record[0], record[3][0], record[3][1]))

    if not OUT_TO_FILE:
        conn.commit()
        cur.close()
        conn.close()

if __name__ == '__main__':
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print('Usage:\n %s ZONEFILE ORIGIN-DOMAIN.ORG\n' % sys.argv[0])
    else:
        records_list = read_file(sys.argv[1])
        if len(sys.argv) > 2:
            insert_records(records_list, sys.argv[2])
        else:
            insert_records(records_list)
