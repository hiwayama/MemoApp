package MemoApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use MemoApp::DB;
use DateTime;
use Data::Dumper;

filter 'connect' => sub {
  my $app  = shift;

  my $conf_file = 'conf.perl';

  sub {
    my ($self, $c) = @_;
    my $conf = do $conf_file or die "$!$@";

    $c->stash->{site_name} = __PACKAGE__;
    
    my $db_conf = $conf->{production};
    $c->stash->{db} ||= MemoApp::DB->new(
      connect_info=>[
        "dbi:$db_conf->{database}:$db_conf->{dbname}",
        $db_conf->{user} ,
        $db_conf->{passwd}, 
        +{
          mysql_enable_utf8 => 1
        }
      ]
    );

    $app->($self, $c);
  }  
};

filter 'todo_list' => sub {
  my $app = shift;

  sub {
    my ($self, $c) = @_;

    my $page = $c->req->param("page") || 1;

    my $db = $c->stash->{db};

    $c->stash->{page} = $page;
    $c->stash->{rows} = $db->all($page-1);

    $app->($self, $c);
  }
};

get '/todos/' => [qw/connect todo_list/] => sub {
  my ( $self, $c )  = @_;

  my $rows = $c->stash->{rows};
  my $page = $c->stash->{page};
  $c->render('index.tx', 
    { rows => $rows , page => $page}
  );
};
get '/todos.json' => [qw/connect todo_list/] => sub {
  my ( $self, $c )  = @_;

  my $rows = $c->stash->{rows};

  my @todos = map {
    id    => $_->id, 
    name  => $_->name,
    comment   => $_->comment, 
    is_done   => $_->is_done, 
    deadline  => $_->deadline, 
  }, @$rows;

  $c->render_json(\@todos);
};


filter 'detail' => sub {
  my $app = shift;

  sub {
    my ($self, $c) = @_;

    my $db = $c->stash->{db};

    my $id = $c->args->{id};

    # TODO id がinvalidだったら戻らせる

    my $row = $db->single('todos', {id => $id});

    $c->stash->{row} = $row;
    
    $app->($self, $c);
  }
};

get '/todos/:id.json' => [qw/connect detail/] => sub {
  my ( $self, $c )  = @_;
  
  my $row = $c->stash->{row};

  my $todo = +{
    id => $row->id.
    name => $row->name, 
    comment => $row->comment, 
    deadline => $row->deadline
  };

  $c->render_json(todo => $todo );
};
get '/todos/:id/' =>[qw/connect detail/] => sub {
  my ( $self, $c )  = @_;
  
  my $row = $c->stash->{row};

  $c->render('detail.tx',
    { row => $row } 
  );
};


post '/todos/:id/delete' => [qw/connect/] => sub {
  my ($self, $c) = @_;

  my $id = $c->args->{'id'};  
  my $db = $c->stash->{db};

  $db->delete('todos', {id => $id});

  $c->redirect('/todos/'); 
};

post '/todos/:id/update' => [qw/connect/] => sub {
  my ( $self, $c) = @_;
 
  my $id = $c->args->{id};

  my $db = $c->stash->{db};
  my $row = $db->single('todos', {id => $id});
  
  my $name = $c->req->param('name') || $row->name;
  my $comment = $c->req->param('comment') || $row->comment;
  my $deadline = $c->req->param('deadline') || $row->deadline;
  my $is_done = $c->req->param('is_done');

  $row->update({
    'name' => $name, 
    'comment' => $comment, 
    'deadline' => $deadline, 
    'is_done' => $is_done, 
  });

  $c->redirect('/todos/');
};

post '/todos/new' => [qw/connect/] => sub {
  my ( $self, $c) = @_;
  
  my $result = $c->req->validator([
    'name' => {
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
      $db->insert('todos' => {
        'name' => $result->valid->get('name'), 
        'created_at' => DateTime->now(time_zone => 'local')
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

