use utf8;
package Apokalo::Schema::Result::HttpRequest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Apokalo::Schema::Result::HttpRequest

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<http_request>

=cut

__PACKAGE__->table("http_request");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v4()
  is_nullable: 0
  size: 16

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 method

  data_type: 'varchar'
  is_nullable: 0
  size: 4

=head2 headers

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 url

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 body

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 retry_until

  data_type: 'timestamp'
  default_value: (now() + '5 days'::interval)
  is_nullable: 0

=head2 retry_each

  data_type: 'interval'
  default_value: '00:00:15'
  is_nullable: 0

=head2 wait_until

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 retry_exp_base

  data_type: 'real'
  default_value: 2
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "method",
  { data_type => "varchar", is_nullable => 0, size => 4 },
  "headers",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "url",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "body",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "retry_until",
  {
    data_type     => "timestamp",
    default_value => \"(now() + '5 days'::interval)",
    is_nullable   => 0,
  },
  "retry_each",
  { data_type => "interval", default_value => "00:00:15", is_nullable => 0 },
  "wait_until",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "retry_exp_base",
  { data_type => "real", default_value => 2, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 http_request_status

Type: might_have

Related object: L<Apokalo::Schema::Result::HttpRequestStatus>

=cut

__PACKAGE__->might_have(
  "http_request_status",
  "Apokalo::Schema::Result::HttpRequestStatus",
  { "foreign.http_request_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 http_responses

Type: has_many

Related object: L<Apokalo::Schema::Result::HttpResponse>

=cut

__PACKAGE__->has_many(
  "http_responses",
  "Apokalo::Schema::Result::HttpResponse",
  { "foreign.http_request_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-06-25 04:58:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:COm21weyV6k94y3QS5daPw

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
