package MemoApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use MemoApp::DB;
use Data::Dumper;

sub connection {
  my $self  = shift;  

  my $teng = MemoApp::DB->new(
    connect_info=>['dbi:SQLite:memo.db',  '', '']
  );
  
  $teng->create_table();

  return $teng;
}

get '/' => sub {
    my ( $self, $c )  = @_;

    my $db = &connection;

    $c->stash->{site_name} = __PACKAGE__;
    my $rows = $db->all();

    $c->render('index.tx', { rows => $rows});
};

post '/p' => sub {
  my ( $self, $c) = @_;
  
  my $db = &connection;
  
  my $result = $c->req->validator([
    'memo' => {
      rule => [
        ['NOT_NULL', 'ENTER SOMETHING!!!'],
      ], 
    }
  ]);
  my $messages = ['success!'];
  if($result->has_error) {
    $messages = $result->messages
  }
  else {
    $db->insert('memos' => {
      'content' => $result->valid->get('memo')
    });
  } 
  
  my $rows = $db->all();
  $c->render('index.tx', {
    rows=>$rows, messages => $messages
  });
 
};

1;

