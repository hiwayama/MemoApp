package MemoApp::DB::Schema;
use Teng::Schema::Declare;
table {
  name 'memos';
  pk 'id';
  columns qw(content);
};
1;
