# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Grab;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use lib qw{t};
use TestDaemon;

my $port = TestDaemon::dotest(1);

my $image = new Image::Grab;
$image->url("http://localhost:$port/testdata/perl.gif");
if($image->grab){
  print "ok 2\n";
} else {
  print "not ok 2\n";
}