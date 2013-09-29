package MemoApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use MemoApp::DB;
use Data::Dumper;

filter 'connect' => sub {
  my $app  = shift;

  my $conf_file = 'conf.perl';

  sub {
    my ($self, $c) = @_;
    my $conf = do $conf_file or die "$!$@";

    my $db_conf = $conf->{production};
    my $db = MemoApp::DB->new(
      connect_info=>[
        "dbi:$db_conf->{database}:$db_conf->{dbname}",
        $db_conf->{user} ,
        $db_conf->{passwd}
      ]
    );
    
    $c->stash->{db} = $db;

    $app->($self, $c);
  }  
};

get '/' => [qw/connect/] =>sub {
  my ( $self, $c )  = @_;
  
  $c->stash->{db}->create_table;

  $c->redirect('/0');
};

get '/:page' => [qw/connect/] => sub {
    my ( $self, $c )  = @_;

    my $page = $c->args->{page};

    $c->stash->{site_name} = __PACKAGE__;
    my $db = $c->stash->{db};
    my $rows = $db->all($page);
    $c->render('index.tx', 
      { rows => $rows , page => $page}
    );
};

post '/d' => [qw/connect/] => sub {
  my ($self, $c) = @_;
  my $result = $c->req->validator([
    'id' => {
      rule => [
        ['UINT', 'ERROR!!!'], 
      ], 
    }
  ]);

  my $id = $result->valid->get('id');  
  my $db = $c->stash->{db};

  print STDOUT Dumper($result->valid);
  print STDOUT "----- $id -----\n";
  $db->delete('memos', {id => $id});

  $c->redirect('/0'); 
};

post '/p' => [qw/connect/] => sub {
  my ( $self, $c) = @_;
  
  my $result = $c->req->validator([
    'memo' => {
      rule => [
        ['NOT_NULL', 'ENTER SOMETHING!!!'],
      ], 
    }
  ]);

  my $db = $c->stash->{db};
  my $messages =  do {
    if($result->has_error) {
      $result->messages
    }
    else {
      $db->insert('memos' => {
        'content' => $result->valid->get('memo')
      });
      ["success!"];  
    }
  };
  my $rows = $db->all();

  $c->render('index.tx', {
    rows=>$rows, messages => $messages, page=>0
  });
 
};

1;

