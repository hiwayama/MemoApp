package MemoApp::DB;
use parent 'Teng';

# テーブルが既に存在している時はなにもしない
sub create_table {
  my $self = shift;
  $self->do(q{
    CREATE TABLE IF NOT EXISTS `memos` (
      `id` INTEGER NOT NULL, 
      `content` TEXT NOT NULL, 
      PRIMARY KEY(`id`)
    )
  });
}

sub all {
  my $self = shift;
  return $self->search('memos', {})->all;
}

1;
