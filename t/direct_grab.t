use strict;
use Image::Grab;
use Cwd;

print "1..1\n";

my $pwd = cwd;
$ENV{DOMAIN} ||= "example.com"; # Net::Domain warnings
my $image = Image::Grab->grab(URL=>"file://" . $pwd . "/t/data/perl.gif");

if(defined $image) {
   print "ok 1\n";
} else {
   print "not ok 1\n";
}

