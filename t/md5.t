
BEGIN { $| = 1; print "1..2\n"; }

unless (-f 't/test') {
  print "1..0\n";
  exit 0;
}

use Image::Grab;

my $image = new Image::Grab;
$image->url("http://everybody.org/mah/testdata/perl.gif");
my $r = $image->grab;
print "not "
  unless defined $r;
print "ok 1\n";

if(defined $r && $image->md5 eq "8065abdcf39da2554592d847d7901e4a") {
   print "ok 2\n";
} else {
   print "not ok 2\n";
}

