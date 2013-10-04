package MemoApp::DB;
use parent 'Teng';

# テーブルが既に存在している時はなにもしない
sub create_table {
  my $self = shift;
  $self->do(q{
    CREATE TABLE IF NOT EXISTS `todos` (
      `id` INT NOT NULL AUTO_INCREMENT, 
      `name` TEXT NOT NULL,
      `deadline` DATETIME,
      `comment` TEXT,  
      `is_done` BOOLEAN NOT NULL DEFAULT FALSE, 
      `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
      `created_at` TIMESTAMP NOT NULL, 
      PRIMARY KEY(`id`)
    )
  });
}

# arrayに変換して返す
# deadlineの降順
sub all {
  my ($self, $page) = @_;
  
  if($page<0){
    return ();
  }

  my $limit = 10;
  
  return $self->search('todos', {}, 
      {limit=>$limit, offset=>$page*$limit, order_by => 'deadline'}
    )->all;
}

1;
