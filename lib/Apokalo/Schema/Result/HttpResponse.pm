use utf8;
package Apokalo::Schema::Result::HttpResponse;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Apokalo::Schema::Result::HttpResponse

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

=head1 TABLE: C<http_response>

=cut

__PACKAGE__->table("http_response");

=head1 ACCESSORS

=head2 http_request_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 response

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 took

  data_type: 'interval'
  is_nullable: 0

=head2 try_num

  data_type: 'smallint'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "http_request_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "response",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "took",
  { data_type => "interval", is_nullable => 0 },
  "try_num",
  { data_type => "smallint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</http_request_id>

=item * L</try_num>

=back

=cut

__PACKAGE__->set_primary_key("http_request_id", "try_num");

=head1 RELATIONS

=head2 http_request

Type: belongs_to

Related object: L<Apokalo::Schema::Result::HttpRequest>

=cut

__PACKAGE__->belongs_to(
  "http_request",
  "Apokalo::Schema::Result::HttpRequest",
  { id => "http_request_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 http_request_statuses

Type: has_many

Related object: L<Apokalo::Schema::Result::HttpRequestStatus>

=cut

__PACKAGE__->has_many(
  "http_request_statuses",
  "Apokalo::Schema::Result::HttpRequestStatus",
  {
    "foreign.http_request_id" => "self.http_request_id",
    "foreign.try_num"         => "self.try_num",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-08-09 11:02:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EM+qTVN+w6giSRKcT11SPg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
