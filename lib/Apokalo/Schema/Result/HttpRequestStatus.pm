use utf8;
package Apokalo::Schema::Result::HttpRequestStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Apokalo::Schema::Result::HttpRequestStatus

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

=head1 TABLE: C<http_request_status>

=cut

__PACKAGE__->table("http_request_status");

=head1 ACCESSORS

=head2 http_request_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 done

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 try_num

  data_type: 'smallint'
  default_value: 1
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "http_request_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "done",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "try_num",
  {
    data_type      => "smallint",
    default_value  => 1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</http_request_id>

=back

=cut

__PACKAGE__->set_primary_key("http_request_id");

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

=head2 http_response

Type: belongs_to

Related object: L<Apokalo::Schema::Result::HttpResponse>

=cut

__PACKAGE__->belongs_to(
  "http_response",
  "Apokalo::Schema::Result::HttpResponse",
  { http_request_id => "http_request_id", try_num => "try_num" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-08-09 11:02:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EY9pV0XXXkg43nDlfilY4Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
