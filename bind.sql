--
-- Database schema
--

CREATE TABLE "record" (
  id BIGSERIAL PRIMARY KEY,
  ttl INTERVAL DEFAULT NULL,
  internal BOOLEAN NOT NULL DEFAULT TRUE,
  external BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE soa (
  zone VARCHAR(1024) NOT NULL UNIQUE,           -- zone name
  ttl INTERVAL NOT NULL DEFAULT '20 min',       -- time to live
  mname VARCHAR(1024) NOT NULL,                 -- the original or primary source of data for this zone
  rname VARCHAR(1024) NOT NULL,                 -- responsible person's email
  serial CHAR(10) NOT NULL DEFAULT              -- number of the original copy of the zone
     regexp_replace(current_date::text, '(....)-(..)-(..)', '\1\2\3') || '01', -- generate serial from date
  refresh INTERVAL NOT NULL DEFAULT '3 hours',  -- time interval before the zone should be refreshed
  retry INTERVAL NOT NULL DEFAULT '1 hour',     -- time interval that should elapse before a failed refresh should be retried
  expire INTERVAL NOT NULL DEFAULT '1 month',   -- time interval that can elapse before the zone is no longer authoritative
  minimum INTERVAL NOT NULL DEFAULT '1 day'     -- minimum TTL field that should be exported with any RR from this zone
) INHERITS(record);

CREATE TABLE xfr (
  zone VARCHAR(1024) NOT NULL REFERENCES soa(zone) ON DELETE CASCADE,
  client VARCHAR(256)
) INHERITS(record);

CREATE TABLE d_record (
  host VARCHAR(256) NOT NULL DEFAULT '@',
  zone VARCHAR(1024) NOT NULL REFERENCES soa(zone) ON DELETE CASCADE
) INHERITS(record);

CREATE TABLE ns (
  nsdname VARCHAR(256) NOT NULL
) INHERITS (d_record);

CREATE TABLE a (
  address INET NOT NULL
) INHERITS (d_record);

CREATE TABLE aaaa (
  address INET NOT NULL
) INHERITS (d_record);

CREATE TABLE txt (
  txt_data TEXT NOT NULL
) INHERITS (d_record);

CREATE TABLE spf (
  txt_data TEXT NOT NULL
) INHERITS (d_record);

CREATE TABLE mx (
  priority integer NOT NULL DEFAULT 10,
  exchange VARCHAR NOT NULL
) INHERITS (d_record);

CREATE TABLE cname (
  cname VARCHAR(256) NOT NULL
) INHERITS (d_record);

CREATE TABLE srv (
  priority integer NOT NULL,
  weight integer NOT NULL,
  port integer NOT NULL,
  target VARCHAR NOT NULL
) INHERITS (d_record);

CREATE TABLE ptr (
  ptrdname VARCHAR(256) NOT NULL
) INHERITS (d_record);

CREATE TABLE hinfo (
  cpu VARCHAR(256),
  os VARCHAR(256),
  constraint cpu_os_not_null check (coalesce(cpu, os) is NOT NULL) -- at least one of `cpu', `os' must be not null
) INHERITS (d_record);


-- returns ttl as seconds, returns soa-record's ttl if this record's tll is null
CREATE OR REPLACE FUNCTION ttl(r_ttl INTERVAL, soa_ttl INTERVAL) RETURNS DOUBLE PRECISION AS $$
BEGIN
  IF r_ttl ISNULL THEN
    RETURN extract('epoch' FROM soa_ttl);
  ELSE
    RETURN extract('epoch' FROM r_ttl);
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE d_record_t AS (
  priority TEXT,
  data TEXT
);

-- CREATE OR REPLACE LANGUAGE plpython3u;
CREATE OR REPLACE FUNCTION data(id BIGINT, rectype TEXT) RETURNS d_record_t as $$
priority_types = ('mx', 'srv')
data_types = {
    'a':     ' host(address) ',
    'aaaa':  ' host(address) ',
    'mx':    ' exchange ',
    'txt':   """ '"' || txt_data || '"' """,
    'spf':   """ '"' || txt_data || '"' """,
    'srv':   """ weight::text || ' ' || port::text || ' ' || target::text """,
    'cname': ' cname ',
    'ptr':   ' ptrdname ',
    'hinfo': """ cpu || ' ' || os """
}

if rectype not in data_types.keys():
    print('WARNING: Trying to get data from unknown record type "{0}"!'.format(rectype))
    return None

if id is None:
    print('WARNING: Trying to access non-existant record of type "{0}"!'.format(rectype))
    return None

priority = 'priority' if rectype in priority_types else 'NULL'

data = plpy.execute('SELECT {select} as data, {priority} as priority FROM "{table}" WHERE id={id}'.format(
    select=data_types[rectype],
    priority=priority,
    table=rectype,
    id=id
), 1)

if data:
    return data[0]
else:
    return {'data': None, 'priority': None}
$$ LANGUAGE plpython3u;

-- view returning records of all types except `NS' and `SOA'
CREATE VIEW d_records AS
SELECT
  s.zone                            AS zone,
  r.host                            AS host,
  ttl(r.ttl, s.ttl)                 AS ttl,
  upper(r.tableoid::regclass::TEXT) AS type,
  d.data                            AS data,
  d.priority                        AS priority,
  r.internal                        AS internal,
  r.external                        AS external
FROM
  d_record r,
  data(r.id, r.tableoid::regclass::TEXT) d,
  soa s
WHERE
  r.zone=s.zone;

-- view returning `NS' and `SOA' record types
CREATE VIEW ns_records as
  SELECT
    ttl(ns.ttl, soa.ttl) AS ttl,
    'NS' as type,
    NULL as priority,
    nsdname as data,
    NULL as resp_person,
    NULL as serial,
    NULL as refresh,
    NULL as retry,
    NULL as expire,
    NULL as minimum,
    soa.zone,
    host,
    ns.internal,
    ns.external
    from ns, soa where soa.zone = ns.zone
  UNION
  SELECT
    extract('epoch' from ttl) as ttl,
    'SOA' as type,
    NULL as priority,
    mname as data,
    rname as resp_person,
    serial,
    extract('epoch' from refresh),
    extract('epoch' from retry),
    extract('epoch' from expire),
    extract('epoch' from minimum),
    zone,
    '@' as host,
    internal,
    external
    from soa
;

-- view returning all types of records
CREATE VIEW all_records as
  SELECT
    ttl,
    type,
    host as host,
    priority,
    data,
    NULL as resp_person,
    NULL as serial,
    NULL as refresh,
    NULL as retry,
    NULL as expire,
    NULL as minimum,
    zone,
    internal,
    external
    from d_records
  UNION
  SELECT
    ttl,
    type,
    host,
    priority,
    data,
    resp_person,
    serial,
    refresh,
    retry,
    expire,
    minimum,
    zone,
    internal,
    external
    from ns_records
;

