
BEGIN { $| = 1; print "1..1\n"; }
use Image::Grab;

my $image = new Image::Grab;
$image->url("http://everybody.org/testdata/perl.gif");
$image->grab;

if($image->md5 eq "1c4ba43ed836e808f755c2a7ea281a99"){
   print "ok 1\n";
} else {
   print "not ok 1\n";
}

