-- Deploy httpcallback:0006-triggernotify to pg
-- requires: 0005-retry_multiplier

BEGIN;


CREATE FUNCTION http_inserted_notify() RETURNS trigger AS $emp_stamp$
    BEGIN
        NOTIFY newhttp;
        RETURN NULL;
    END;
$emp_stamp$ LANGUAGE plpgsql;


CREATE TRIGGER tgr_http_inserted
    AFTER INSERT ON http_request
    FOR EACH STATEMENT
    EXECUTE PROCEDURE http_inserted_notify();

COMMIT;
