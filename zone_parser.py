#!/usr/bin/python

import sys, re
from functools import reduce

def stripcom(s):
    '''Takes string as parameter and returns same string with
    comments stripped out'''
    #if not s: return None

    # if `;' charachter placed in quoted substring it does not mean 
    # beginning of the comment
    if '"' not in s:
        # string doesn't contain any quote
        if ';' in s:
            r = s[:s.find(';')].rstrip()
        else:
            r = s.rstrip()
    else:
        # string contain at least one quote
        if s.count('"')%2:
            print('Syntax error: not found matching quote')
            return None
        if ';' not in s:
            r = s.rstrip()
        else:
            r = s.rstrip()
            quote_closed = True
            for x in range(len(s)):
                if quote_closed:
                    if s[x] == ';': 
                        r = s[:x].rstrip()
                        break
                    if s[x] == '"':
                        quote_closed = False
                else:
                    if s[x] == '"': quote_closed = True
                    
    return r

def normalize1(l, s, ml=False):
    '''Function to use it with reduce() normalizing multiline
    records with `(' and `)' to single-line without parentheses'''
    if not s:
        r = []
    else:
        r = [s]
    if globals()['ml']:
        if s.endswith(')'):
            globals()['ml'] = False
            s = s[:-1].rstrip()
        if s.lstrip().startswith('"'):
            l[-1] += s[s.find('"')+1:]
        else:
            l[-1] += s
        return l
    if '(' in s:
        globals()['ml'] = True
        if s.endswith('"'):
            r = [s[:s.find('(')] + s[s.find('(')+1:s.rfind('"')]]
        else:
            r = [s[:s.find('(')]]
    return l + r

def parse_mx(s):
    return re.match(r'(\d+)\s+(.+)', s).groups()
    

def read_file(filename):
    '''Reads zone file and returns list of tuples of records;
    format of output tuples:
        (host, ttl, type_of_record, (tuple of data))
    where tuple of data contain just one string for A, AAAA, NS etc
    records and several strings for SOA, MX or SRV records.
    Does not support $INCLUDE.'''
    with open(filename) as fd:
        fb = fd.readlines()
    ret_list = []
    host = None
    zone = None
    ttl = None
    types_dic = {
            'SOA': r'^([\w\d\._-]+|@)\s+([\w\d\._-]+|@)\s+(\d{10})\s+(\d+[h|d|w]?)\s+(\d+[h|d|w]?)\s+(\d+[h|d|w]?)\s+(\d+[h|d|w]?)$',
            'NS': r'^(.+)$',
            'MX': r'^(\d+)\s+(.*)$',
            'A': r'^(\d{1,3}\.\d{1,3}.\d{1,3}.\d{1,3})$',
            'AAAA': r'^([\da-fA-F:]+)$',
            'CNAME': r'^(.+)$',
            'TXT': r'^"(.*)"$',
            'SPF': r'^"(.*)"$',
            'SRV': r'^(\d+)\s(\d+)\s(\d+)\s(.*)$',
            'HINFO': r'^(\w+)\s+(\w+)$'
            }
    for s in reduce(normalize1, map(stripcom, fb), []):
        if s.startswith('$'):
            r = re.match('^\$(ORIGIN|TTL|INCLUDE)\s+(.*)', s)
            if r.group(1) == 'ORIGIN': zone = r.group(2)
            elif r.group(1) == 'TTL': ttl = r.group(2)
            elif r.group(1) == 'INCLUDE': print('INCLUDES NOT SUPPORTED')
        else:
            if host is None:
                host = zone
            t = re.search(
                    r'([\w\d\._-]+|@)?\s+(\d+[HhDdWw]?)?\s*(IN)?\s*(SOA|NS|MX|A|AAAA|CNAME|TXT|SPF|PTR|SRV|HINFO)\s+(.+)',
                    s ).groups()
            print (t)
            if t[0]:
                host = t[0]
                if t[3] == 'SOA' and t[0] == '@':
                    if zone: host = zone + '.'
            ret_list += [(host, ttl, t[3], re.match(types_dic[t[3]], t[4]).groups())]
    return ret_list

if __name__ == '__main__':
    for t in read_file(sys.argv[1]):
        print('%s\t%s\t%s\t%s' % t)

