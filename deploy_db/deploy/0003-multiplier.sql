-- Deploy httpcallback:0003-multiplier to pg
-- requires: 0002-wait_until

BEGIN;

alter table http_request drop retry_multiplier;
alter table http_request add column retry_multiplier real;

COMMIT;
