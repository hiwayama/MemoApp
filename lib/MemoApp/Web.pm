package MemoApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use Kossy::Validator;
use MemoApp::DB;

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

    print "aaaaaaaaaaaaaaaaaaaa";
    print "---".$db->all()."---";
    
    $c->stash->{site_name} = __PACKAGE__;
    my $rows = $db->all();

    $c->render('index.tx', { rows => $rows});
};

post '/p' => sub {
  my ( $self, $c) = @_;
  my $result = Kossy::Validator->check($c, [
    'memo' => {
      rule => [
        ['NOT_NULL', 'ENTER SOMETHING!!!'],
      ], 
    }
  ]);
  if($result->has_error) {
    return $c->render_json({
      error => 1, 
      messages => $result->errors
    });
  }
  else {
    my $teng = &connection;

    $teng->insert('memos' => {
      'content' => $result->valid->get('tbox')
    });
    $c->render('index.tx');
  }
 
};

1;

