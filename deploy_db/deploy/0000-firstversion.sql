-- Deploy httpcallback:0000-firstversion to pg
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

BEGIN;

create table http_request (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY ,
    created_at timestamp without time zone not null default now(),
    method varchar(4) not null,
    headers varchar,
    host varchar not null,
    body varchar,
    secure boolean not null default true,
    retry_until timestamp without time zone not null default now() + '5 days',
    retry_each interval not null default '15 seconds',
    retry_multiplier smallint not null default 2
);

create table http_request_status (
    http_request_id uuid NOT NULL,
    done boolean not null default false,
    try_num smallint not null default 1,
    PRIMARY key (http_request_id),
    FOREIGN KEY (http_request_id) REFERENCES http_request(id)
);

create table http_response (
    http_request_id uuid NOT NULL,
    created_at timestamp without time zone not null default now(),
    response varchar not null,
    took interval not null,
    try_num smallint not null default 1,
    PRIMARY key (http_request_id, try_num),
    FOREIGN KEY (http_request_id) REFERENCES http_request(id)
);

COMMIT;
