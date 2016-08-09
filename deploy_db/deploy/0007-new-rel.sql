-- Deploy httpcallback:0007-new-rel to pg
-- requires: 0006-triggernotify

BEGIN;
ALTER TABLE http_request_status
  ADD FOREIGN KEY (http_request_id, try_num) REFERENCES http_response (http_request_id, try_num) ON UPDATE NO ACTION ON DELETE NO ACTION;


COMMIT;
