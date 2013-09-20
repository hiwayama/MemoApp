package MemoApp::DB;
use parent 'Teng';

# テーブルが既に存在している時はなにもしない
sub create_table {
  my $self = shift;
  $self->do(q{
    CREATE TABLE IF NOT EXISTS `memos` (
      `id` INTEGER NOT NULL AUTO_INCREMENT, 
      `content` TEXT NOT NULL, 
      PRIMARY KEY(`id`)
    )
  });
}

# arrayに変換
sub all {
  my ($self, $page) = @_;
  
  if($page<0){
    return ();
  }

  my $limit = 10;
  
  return $self->search('memos', {}, 
      {limit=>$limit, offset=>$page*$limit, order_by => 'id'}
    )->all;
}

1;
