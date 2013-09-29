package MemoApp::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;

table {
  name 'memos';
  pk 'id';
  columns qw(id content create_at update_at);

  inflate qr/_at$/ => sub {
    DateTime::Format::MySQL->parse_datetime(shift);
  };
                      
  deflate qr/_at$/ => sub {
    DateTime::Format::MySQL->format_datetime(shift);
  };
};
1;
