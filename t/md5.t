# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

BEGIN { $| = 1; print "1..1\n"; }
use Image::Grab;

use lib qw{t};
use TestDaemon;

my $port = TestDaemon::dotest(1);

my $image = new Image::Grab;
$image->url("http://localhost:$port/testdata/perl.gif");
$image->grab;

if($image->md5 eq "1c4ba43ed836e808f755c2a7ea281a99"){
   print "ok 1\n";
} else {
   print "not ok 1\n";
}

