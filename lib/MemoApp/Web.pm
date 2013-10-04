package MemoApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use JSON;
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
          'mysql_enable_utf8' => 1
        }
      ]
    );

    $app->($self, $c);
  }  
};

# ---------------------- #
# 一覧表示
#
# /todos/
# /todos.json
# ---------------------- #
filter 'todo_list' => sub {
  my $app = shift;

  sub {
    my ($self, $c) = @_;

    my $page = $c->req->param("page") || 1;
    my $q   = $c->req->param("q");

    my $db = $c->stash->{db};

    $c->stash->{page} = $page;
    
    my $todos = do {
      if(defined($q)) { 
        $db->find($q, $page-1);
      } else {
        $db->find_all($page-1);
      }
    };

#    my $todos = $db->all($page-1);

    my @todos = map {
      id    => $_->id, 
      name  => $_->name,
      comment   => $_->comment, 
      is_done   => $_->is_done, 
      deadline  => $_->deadline, 
    }, @$todos;

    $c->stash->{todos} = \@todos;

    $app->($self, $c);
  }
};

get '/todos/' => [qw/connect todo_list/] => sub {
  my ( $self, $c )  = @_;

  my $todos = $c->stash->{todos};
  my $page = $c->stash->{page};
  $c->render('index.tx', 
    { rows => $todos , page => $page}
  );
};
get '/todos.json' => [qw/connect todo_list/] => sub {
  my ( $self, $c )  = @_;

  my $page = $c->stash->{page};
  my $todos = $c->stash->{todos};

  $c->render_json({todos=>$todos, page=>$page});
};


# ------------------- #
# 個別詳細表示
#
# ------------------- #
filter 'detail' => sub {
  my $app = shift;

  sub {
    my ($self, $c) = @_;

    my $db = $c->stash->{db};

    my $id = $c->args->{id};

    # TODO id がinvalidだったら戻らせる

    my $row = $db->single('todos', {id => $id});
    
    my $todo = +{
      id        => $row->id, 
      name      => $row->name, 
      comment   => $row->comment, 
      deadline  => $row->deadline
    };
  
    $c->stash->{todo} = $todo;
    
    $app->($self, $c);
  }
};
get '/todos/:id.json' => [qw/connect detail/] => sub {
  my ( $self, $c )  = @_;

  my $todo = $c->stash->{todo};

  $c->render_json({todo => $todo});
};
get '/todos/:id/' =>[qw/connect detail/] => sub {
  my ( $self, $c )  = @_;
 
  my $todo = $c->stash->{todo};

  $c->render('detail.tx',
    { todo => $todo } 
  );
};


# ------------------ #
# 個別削除
#
# ------------------ #
post '/todos/:id/delete' => [qw/connect/] => sub {
  my ($self, $c) = @_;

  my $id = $c->args->{'id'};  
  my $db = $c->stash->{db};

  $db->delete('todos', {id => $id});

  $c->redirect('/todos/'); 
};

# -------------------- #
# 個別更新
#
# -------------------- #
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


# -------------------- #
# 新規作成
#
# -------------------- #
post '/todos/new' => [qw/connect/] => sub {
  my ( $self, $c) = @_;
  
  my $name = $c->req->param('name');
  my $comment = $c->req->param('comment');
  my $deadline = $c->req->param('deadline');

  my $db = $c->stash->{db};
  $db->insert('todos' => {
    'name' => $name,
    'deadline' => $deadline, 
    'comment' => $comment,  
    'created_at' => DateTime->now(time_zone => 'local')
  });
  my $rows = $db->find_all();
  my $messages = ["success!!"];
  $c->render('index.tx', {
    rows=>$rows, messages => $messages, page=>0
  });
 
};

1;

