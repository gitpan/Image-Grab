BEGIN { $| = 1; print "1..1\n"; }
use Image::Grab;
use diagnostics;


unless (-f 't/test') {
  print "1..0\n";
  exit 0;
}

$image = Image::Grab->grab(URL=>"http://everybody.org/testdata/perl.gif");

if(defined $image) {
   print "ok 1\n";
} else {
   print "not ok 1\n";
}

