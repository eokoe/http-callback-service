-- Deploy httpcallback:0005-retry_multiplier to pg
-- requires: 0004-fix-mult

BEGIN;

alter table http_request rename retry_multiplier  to retry_exp_base;

COMMIT;
