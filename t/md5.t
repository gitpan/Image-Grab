# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

BEGIN { $| = 1; print "1..1\n"; }
use Image::Grab;

my $image = new Image::Grab;
$image->refer("http://www.eecs.tulane.edu/~mah");
$image->url("#1");
$image->grab;

open(TMP, "|md5>/tmp/$$.md5");
print TMP $image->image;
close(TMP);

open(TMP, "</tmp/$$.md5");
chomp(my $md5sum=<TMP>);
close(TMP);

if($image->md5 eq $md5sum){
   print "ok 1\n";
} else {
   print "not ok 1\n";
}

