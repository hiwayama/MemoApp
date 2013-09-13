use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/lib";
use File::Basename;
use File::Spec;
use YAML::Syck;
use Plack::Builder;
use MemoApp::Web;

my $root_dir = File::Basename::dirname(__FILE__);

#
my $abs = File::Spec->rel2abs($root_dir);
print $abs."\n";

my $conf = YAML::Syck::LoadFile($abs."/sample.yaml");

print $conf->{development}->{database};
#

my $app = MemoApp::Web->psgi($root_dir);
builder {
    enable 'ReverseProxy';
    enable 'Static',
        path => qr!^/(?:(?:css|js|img)/|favicon\.ico$)!,
        root => $root_dir . '/public';
    $app;
};

