drop table if exists record_nview cascade;
drop table if exists nview cascade;
drop table if exists soa cascade;
drop table if exists record cascade;
drop table if exists a cascade;
drop table if exists aaaa cascade;
drop table if exists mx cascade;
drop table if exists ns cascade;
drop table if exists txt cascade;
drop table if exists spf cascade;
drop table if exists srv cascade;
drop table if exists xfr cascade;
drop table if exists cname cascade;
drop table if exists ptr cascade;
drop table if exists hinfo cascade;
drop view if exists d_records cascade;
drop view if exists ns_records cascade;
drop view if exists all_records cascade;
DROP FUNCTION IF EXISTS data(BIGINT, TEXT);
DROP FUNCTION IF EXISTS ttl(INTERVAL, INTERVAL);
drop TYPE if exists d_record_t cascade;