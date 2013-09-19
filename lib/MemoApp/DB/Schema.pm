package MemoApp::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;

table {
  name 'memos';
  pk 'id';
  columns qw(id content);
};
1;
