package MemoApp::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;
use DateTime::Format::MySQL;

table {
  name 'memos';
  pk 'id';
  columns qw(id content created_at updated_at);

  inflate qr/_at$/ => sub {
    DateTime::Format::MySQL->parse_datetime(shift);
  };
                      
  deflate qr/_at$/ => sub {
    DateTime::Format::MySQL->format_datetime(shift);
  };
};
1;
