# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Image::Grab;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my $image = new Image::Grab;
$image->refer("http://www.eecs.tulane.edu/~mah");
$image->url("#1");
if($image->grab){
  print "ok 2\n";
} else {
  print "not ok 2\n";
}