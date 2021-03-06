use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/lib";
use File::Basename;
use File::Spec;
use Plack::Builder;
use MemoApp::Web;

my $root_dir = File::Basename::dirname(__FILE__);

my $app = MemoApp::Web->psgi($root_dir);
builder {
    enable 'ReverseProxy';
    enable 'Static',
        path => qr!^/(?:(?:css|js|img)/|favicon\.ico$)!,
        root => $root_dir . '/public';
    $app;
};

