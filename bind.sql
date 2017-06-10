--
-- Database schema
--

create table soa (
	id BIGSERIAL PRIMARY KEY,
  zone VARCHAR(1024) NOT NULL UNIQUE ,          -- zone name
  ttl INTERVAL not NULL default '20 min',       -- time to live
  mname VARCHAR(1024) not NULL,                 -- the original or primary source of data for this zone
  rname VARCHAR(1024) not NULL,                 -- responsible person's email
  serial CHAR(10) not NULL default              -- number of the original copy of the zone
     regexp_replace(current_date::text, '(....)-(..)-(..)', '\1\2\3') || '01', -- generate serial from date
  refresh INTERVAL not NULL default '3 hours',  -- time interval before the zone should be refreshed
  retry INTERVAL not NULL default '1 hour',     -- time interval that should elapse before a failed refresh should be retried
  expire INTERVAL not NULL default '1 month',   -- time interval that can elapse before the zone is no longer authoritative
  minimum INTERVAL not NULL default '1 day'     -- minimum TTL field that should be exported with any RR from this zone
);

create table a (
  zone BIGINT not NULL references soa on delete cascade,    -- zone must exists in soa table
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  address inet not NULL
);

create table aaaa (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  address INET not NULL
);

create table txt (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  txt_data TEXT not NULL
);

create table spf (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  txt_data TEXT not NULL
);

create table ns (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  nsdname VARCHAR(256) not NULL
);

create table mx (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  preference integer not NULL default 10,
  exchange VARCHAR not NULL
);

create table cname (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL,
  cname VARCHAR(256) not NULL
);

create table srv (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  priority integer not NULL,
  weight integer not NULL,
  port integer not NULL,
  target VARCHAR not NULL
);

create table ptr (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  ptrdname VARCHAR(256) not NULL
);

create table hinfo (
  zone BIGINT not NULL references soa on delete cascade,
  ttl INTERVAL default NULL,
  host VARCHAR(256) not NULL default '@',
  cpu VARCHAR(256),
  os VARCHAR(256),
  constraint cpu_os_not_null check (coalesce(cpu, os) is not NULL) -- at least one of `cpu', `os' must be not null
);

create table xfr (
  zone BIGINT not NULL references soa on delete cascade,
  client VARCHAR(256)
);

-- view returning records of all types except `NS' and `SOA'
create view d_records as
  select 
    host,
    -- if `ttl' in table `a' is not NULL select its value. Select value of `soa.ttl' in other case.
    case when a.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from a.ttl) end as ttl,
    'A' as type,
    NULL as priority,
    host(address) as data, 
    soa.zone
    from a, soa where soa.id = a.zone
  union
  select
    host,
    case when aaaa.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from aaaa.ttl) end as ttl,
    'AAAA' as type,
    NULL as priority,
    host(address) as data,
    soa.zone
    from aaaa, soa where soa.id = aaaa.zone
  union
  select
    host,
    case when mx.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from mx.ttl) end as ttl,
    'MX' as type,
    preference::text as priority,
    exchange as data,
    soa.zone
    from mx, soa where soa.id = mx.zone
  union
  select
    host,
    case when txt.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from txt.ttl) end as ttl,
    'TXT' as type,
    NULL as priority,
    '"' || txt_data || '"' as data, -- add double quotes to text data cause it can contain whitespaces
    soa.zone
    from txt, soa where soa.id = txt.zone
  union
  select
    host,
    case when spf.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from spf.ttl) end as ttl,
    'SPF' as type,
    NULL as priority,
    '"' || txt_data || '"' as data,
    soa.zone
    from spf, soa where soa.id = spf.zone
  union
  select
    host,
    case when srv.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from srv.ttl) end as ttl,
    'SRV' as type,
    priority::text as priority,
    weight::text || ' ' || port::text || ' ' || target::text as data, -- concatenate fields as DLZ driver do not expect so much elements in tuple returned from postgres
    soa.zone
    from srv, soa where soa.id = srv.zone
  union
  select 
    host,
    case when cname.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from cname.ttl) end as ttl,
    'CNAME' as type,
    NULL as priority,
    cname as data,
    soa.zone
    from cname, soa where soa.id = cname.zone
  union
  select 
    host,
    case when ptr.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from ptr.ttl) end as ttl,
    'PTR' as type,
    NULL as priority,
    ptrdname as data,
    soa.zone
    from ptr, soa where soa.id = ptr.zone
  union
  select 
    host,
    case when hinfo.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from hinfo.ttl) end as ttl,
    'HINFO' as type,
    NULL as priority,
    cpu || ' ' || os as data,
    soa.zone
    from hinfo, soa where soa.id = hinfo.zone
;

-- view returning `NS' and `SOA' record types
create view ns_records as
  select
    case when ns.ttl is NULL then extract('epoch' from soa.ttl) else extract('epoch' from ns.ttl) end as ttl,
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
    host
    from ns, soa where soa.id = ns.zone
  union
  select
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
    '@' as host
    from soa
;

-- view returning all types of records
create view all_records as
  select
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
    zone
    from d_records
  union
  select
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
    zone
    from ns_records
;

