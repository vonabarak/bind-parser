
-- vonabarak.com
INSERT INTO soa (zone, mname, rname) VALUES ('vonabarak.com', 'ns.vonabarak.com.', 'root.vonabarak.com');
INSERT INTO spf(zone, txt_data) VALUES ('vonabarak.com', 'v=spf1 +mx -all');
INSERT INTO txt(zone, txt_data) VALUES ('vonabarak.com', 'v=spf1 +mx -all');
INSERT INTO txt(zone, host, txt_data) VALUES (
  'vonabarak.com',
  'vonabarak._domainkey',
  'v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQD5zXqkXB8se+TRRNostCUwbyG8yaN5HbUQXW6gF' ||
  'LBBizMPDjxNl8EcaEioECVKGflS6Z8R6l1EEE3Mt2/W2vRnzYh36sVbthYH4FZLP16F9ytC8teCJQNeymb+ZjayX70Gq856' ||
  'LB5Wl8TPG/ZFIamcP8Y/DyW2hOsF0dgNU3reWQIDAQAB');
INSERT INTO txt(zone, host, txt_data) VALUES ('vonabarak.com', '_domainkey', 'o=~; r=root@vonabarak.ru');
INSERT INTO txt(zone, host, txt_data) VALUES ('vonabarak.com', '_adsp._domainkey', 'dkim=discardable');
INSERT INTO txt(zone, host, txt_data) VALUES (
  'vonabarak.com',
  '_dmarc',
  'v=DMARC1; p=none; rua=mailto:postmaster@vonabarak.ru');

INSERT INTO a (zone, host, address, internal, external) VALUES
  ('vonabarak.com',         'ns',     '88.198.250.218',  't', 't'),
  ('vonabarak.com',          '@',     '88.198.250.218',  't', 't'),
  ('vonabarak.com',     'wombat',     '212.47.241.37',   't', 't');


-- vonabarak.ru
INSERT INTO soa (zone, mname, rname) VALUES ('vonabarak.ru', 'ns.vonabarak.com.', 'root.vonabarak.ru');
INSERT INTO spf(zone, txt_data) VALUES ('vonabarak.ru', 'v=spf1 +mx -all');
INSERT INTO mx(zone, exchange) VALUES ('vonabarak.ru', 'mx');
INSERT INTO txt(zone, txt_data) VALUES ('vonabarak.ru', 'v=spf1 +mx -all');
INSERT INTO txt(zone, host, txt_data) VALUES (
  'vonabarak.ru',
  'vonabarak._domainkey',
  'v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDT3enwc5Oj+wJym6hWAIua91jHy68lE6UPGGuEi' ||
  '1wQ6F5n8eEHedHpe+fiAsTDBqTv872TEamLxxUw81K38qS/n7nClAITlAC5i+zxUi8TWA+1DUXHdV3Y4mNTM848Krn1+lb7' ||
  '2JcXJOt9zE8M/ZwMRoQr5sttbf1jitfIFK1K3QIDAQAB');
INSERT INTO txt(zone, host, txt_data) VALUES ('vonabarak.ru', '_domainkey', 'o=~; r=root@vonabarak.ru');
INSERT INTO txt(zone, host, txt_data) VALUES ('vonabarak.ru', '_adsp._domainkey', 'dkim=discardable');
INSERT INTO txt(zone, host, txt_data) VALUES (
  'vonabarak.ru',
  '_dmarc',
  'v=DMARC1; p=none; rua=mailto:postmaster@vonabarak.ru');

INSERT INTO aaaa(zone, host, address, internal, external) VALUES
  ('vonabarak.ru',       'mail', '2a01:4f8:a0:228c:1:5:0:181',      't', 't'),
  ('vonabarak.ru',      'felis', '2a01:4f8:a0:228c:1:7::',          't', 't'),
  ('vonabarak.ru',      'larix', '2a01:4f8:a0:228c:1::1',           't', 't'),
  ('vonabarak.ru',        'mx1', '2002:1f83:1241::25',              't', 't'),
  ('vonabarak.ru',       'grus', '2a01:4f8:a0:228c:1:2::',          't', 't'),
  ('vonabarak.ru',  'poudriere', '2a01:4f8:a0:228c:1:3::',          't', 't'),
  ('vonabarak.ru',     'allium', '2a01:4f8:a0:228c:1:4::',          't', 't'),
  ('vonabarak.ru',      'strix', '2a01:4f8:a0:228c:1:5::',          't', 't'),
  ('vonabarak.ru',   'isoptera', '2a01:4f8:a0:228c:1:6::',          't', 't'),
  ('vonabarak.ru',      'vmail', '2a01:4f8:a0:228c:1:5:0:125',      't', 't'),
  ('vonabarak.ru',      'nginx', '2a01:4f8:a0:228c:1:5:0:181',      't', 't'),
  ('vonabarak.ru',      'rcube', '2a01:4f8:a0:228c:1:5:0:182',      't', 't'),
  ('vonabarak.ru',       'trac', '2a01:4f8:a0:228c:1:5:0:183',      't', 't'),
  ('vonabarak.ru',          '@', '2a01:4f8:a0:228c:1:5:0:181',      't', 't'),
  ('vonabarak.ru',         'mx', '2a01:4f8:a0:228c:1:5:0:125',      't', 't');

INSERT INTO a (zone, host, address, internal, external) VALUES
  ('vonabarak.ru',    'isoptera',     '88.198.250.219',  'f', 't'),
  ('vonabarak.ru', 'felis_devel',     '192.168.172.8',   't', 'f'),
  ('vonabarak.ru', 'squid.felis',     '192.168.172.73',  't', 'f'),
  ('vonabarak.ru',       'larix',     '192.168.172.254', 't', 'f'),
  ('vonabarak.ru',          'ns',     '88.198.250.218',  'f', 't'),
  ('vonabarak.ru',         'ns1',     '88.198.250.218',  'f', 't'),
  ('vonabarak.ru',         'ns0',     '88.198.250.218',  'f', 't'),
  ('vonabarak.ru',         'ns2',     '88.198.250.218',  't', 't'),
  ('vonabarak.ru',       'nginx',     '192.168.172.181', 't', 'f'),
  ('vonabarak.ru',           '@',     '88.198.250.220',  't', 't'),
  ('vonabarak.ru',          'mx',     '88.198.250.220',  'f', 't'),
  ('vonabarak.ru',        'grus',     '192.168.172.2',   't', 'f'),
  ('vonabarak.ru',       'larix',     '88.198.35.73',    'f', 't'),
  ('vonabarak.ru',      'allium',     '192.168.172.4',   't', 'f'),
  ('vonabarak.ru',        'mail',     '88.198.250.220',  'f', 't'),
  ('vonabarak.ru', 'pgsql.felis',     '192.168.172.72',  't', 'f'),
  ('vonabarak.ru',        'lynx',     '192.168.172.12',  't', 'f'),
  ('vonabarak.ru',        'lynx',     '88.198.250.222',  'f', 't'),
  ('vonabarak.ru',       'rcube',     '192.168.172.182', 't', 'f'),
  ('vonabarak.ru',     'columba',     '31.131.18.65',    't', 't'),
  ('vonabarak.ru',      'wombat',     '212.47.241.37',   't', 't'),
  ('vonabarak.ru',         'mx1',     '31.131.18.65',    't', 't'),
  ('vonabarak.ru',      'jabber',     '31.131.18.65',    't', 't'),
  ('vonabarak.ru',        'grus',     '88.198.250.218',  'f', 't'),
  ('vonabarak.ru',   'poudriere',     '192.168.172.3',   't', 'f'),
  ('vonabarak.ru',       'strix',     '192.168.172.5',   't', 'f'),
  ('vonabarak.ru',       'strix',     '88.198.250.220',  'f', 't'),
  ('vonabarak.ru',       'vmail',     '192.168.172.125', 't', 'f'),
  ('vonabarak.ru',       'felis',     '192.168.172.7',   't', 'f'),
  ('vonabarak.ru',       'felis',     '88.198.250.221',  'f', 't'),
  ('vonabarak.ru',        'trac',     '192.168.172.183', 't', 'f');



-- v7k.me
INSERT INTO soa (zone, mname, rname) VALUES ('v7k.me', 'ns.vonabarak.com.', 'root.v7k.me');
INSERT INTO spf(zone, txt_data) VALUES ('v7k.me', 'v=spf1 +mx -all');
INSERT INTO mx (zone, exchange) VALUES ('v7k.me', 'mx');
INSERT INTO mx (zone, priority, exchange) VALUES ('v7k.me', 20, 'mx20');
INSERT INTO mx (zone, priority, exchange) VALUES ('v7k.me', 30, 'mx30');
INSERT INTO cname(zone, host, cname) VALUES ('v7k.me', 'www', '@');
INSERT INTO a (zone, host, address, internal, external) VALUES
  ('v7k.me',          '@',         '88.198.250.221',  'f', 't'),
  ('v7k.me',          'felis',     '88.198.250.221',  'f', 't');


-- ptr records
INSERT INTO soa (zone, mname, rname) VALUES ('172.168.192.in-addr.arpa', 'ns.v7k.me', 'root.v7k.me');
INSERT INTO ptr(zone, host, ptrdname, internal, external) VALUES
  ('172.168.192.in-addr.arpa', 2 ,        'grus.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 6 ,   'blattodea.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 12,   'poudriere.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 17,       'tulip.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 7 ,       'felis.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 5 ,       'strix.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 1 ,        'grus.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 8 , 'felis_devel.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 72, 'pgsql.felis.v7k.me.',    't',       'f'),
  ('172.168.192.in-addr.arpa', 73, 'squid.felis.v7k.me.',    't',       'f');
