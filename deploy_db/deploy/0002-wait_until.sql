-- Deploy httpcallback:0002-wait_until to pg
-- requires: 0001-host-url

BEGIN;

alter table http_request add column wait_until timestamp without time zone not null default now();

alter table http_request drop column secure;

COMMIT;
