use Image::Grab;
print "1..1\n";
my $page = new Image::Grab;
chomp(my $pwd = `pwd`);

$ENV{DOMAIN} ||= "example.com"; # Net::Domain warnings
$page->search_url("file:" . $pwd . "/t/data/bkgrd.html");

my @url = $page->getAllURLs;
print "not " unless $url[0] eq "file:" . $pwd . "/t/data/background.jpg";
print "ok 1\n";

