#!/usr/local/bin/perl

BEGIN { $| = 1; }

unless (-f 't/test') {
  print "1..0\n";
  exit 0;
}

use Image::Grab;
my $toons = [
{Name => "Arlo And Janis",
 regexp => "arlonjanis[0-9]+.*\.gif",
 refer => "http://www.unitedmedia.com/comics/arlonjanis/ab.html",
 search_url => "http://www.unitedmedia.com/comics/arlonjanis/ab.html",
},
{Name => "RobotMan",
 regexp => "robotman[0-9]+\.gif",
 refer => "http://www.unitedmedia.com/comics/robotman/ab.html",
 search_url => "http://www.unitedmedia.com/comics/robotman/ab.html",
}];

print "1..", $#{$toons} + 1,"\n";
my $num=0;
my $name;
foreach (@$toons)  {
  $num++;
  $name = $_->{Name};
  print "$name\n";
  $comic->{$name} = new Image::Grab;
  $comic->{$name}->url($_->{url}) if defined $_->{url};
  $comic->{$name}->refer($_->{refer}) if defined $_->{refer};
  $comic->{$name}->regexp($_->{regexp}) if defined $_->{regexp};
  $comic->{$name}->search_url($_->{search_url}) if defined $_->{search_url};

  print "\turl:    ", $_->{url}, "\n" if defined $_->{url};
  print "\trefer:  ", $_->{refer}, "\n" if defined $_->{refer};
  print "\tregexp: ", $_->{regexp}, "\n" if defined $_->{regexp};
  print "\tregexp: ", $_->{search_url}, "\n" if defined $_->{search_url};
  print "\treal:   ", $comic->{$name}->expand_url, "\n";

# getAllURLs should really be fixed so that it only has to fetch once.
  print "\t\t", join("\n\t\t", $comic->{$name}->getAllURLs), "\n" if $_->{search_url};

  print "ok $num\n";
}
