# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

BEGIN { $| = 1; print "1..1\n"; }

unless (-f 't/test') {
  print "1..0\n";
  exit 0;
}

use Image::Grab;

my $image = new Image::Grab;
$image->url("http://everybody.org/testdata/perl.gif");
$image->grab;

if($image->type eq "image/gif"){
   print "ok 1\n";
} else {
   print "not ok 1\n";
}

