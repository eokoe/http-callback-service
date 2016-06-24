-- Deploy httpcallback:0004-fix-mult to pg
-- requires: 0003-multiplier

BEGIN;

alter table http_request drop retry_multiplier;
alter table http_request add column retry_multiplier real not null default 2;

COMMIT;
