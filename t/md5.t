use Image::Grab;
print "1..1\n";

my $image = new Image::Grab;

chomp(my $pwd = `pwd`);
$ENV{DOMAIN} ||= "example.com"; # Net::Domain warnings
$image->url("file:" . $pwd . "/t/data/perl.gif");

$image->grab;

if($image->md5 eq "8065abdcf39da2554592d847d7901e4a") {
   print "ok 1\n";
} else {
   print "not ok 1\n";
}

