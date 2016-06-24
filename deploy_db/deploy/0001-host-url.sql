-- Deploy httpcallback:0001-host-url to pg
-- requires: 0000-firstversion

BEGIN;

alter table http_request rename host to url;

COMMIT;
