#!/usr/local/bin/perl

BEGIN { $| = 1; }
use Image::Grab;
use diagnostics;
my $toons = [
{Name => "One Big Happy",
 url => "http://www.chron.com/content/chronicle/comics/One_Big_Happy.g.gif",
 "link" => "http://www.chron.com/content/comics",
 },
{Name => "9 Chickweed Lane",
 url => "http://www.chron.com/content/chronicle/comics/9_Chickweed_Lane.g.gif",
 "link" => "http://www.chron.com/content/comics",
 },
{Name => "Liberty Meadows",
 url => "http://www.chron.com/content/chronicle/comics/Liberty_Meadows.g.gif",
 "link" => "http://www.chron.com/content/comics",
 },
# This won't work on Sundays.
{Name => "Madam & Eve",
 url => "http://www.mg.co.za/mg/m&e/%y%m/me%y%m%d.gif",
 "link" => "http://www.mg.co.za/mg/m&e/index.htm",
},

{Name => "Lily Wong",
 url => "http://www.reuben.org/lilywong/archive/strips/%y%m%d.gif",
 refer => "http://www.reuben.org/lilywong/",
},

{Name => "Arlo And Janis",
 regexp => "arlonjanis[0-9]+.*\.gif",
 refer => "http://www.unitedmedia.com/comics/arlonjanis/ab.html",
},
{Name => "RobotMan 2",
 regexp => "robotman[0-9]+\.gif",
 refer => "http://www.unitedmedia.com/comics/robotman/ab.html",
}];

print "1..", $#{$toons} + 1,"\n";
$num=0;
foreach (@$toons)  {
  $num++;
  $name = $_->{Name};
  print "$name\n";
  $comic->{$name} = new Image::Grab;
  $comic->{$name}->url($_->{url}) if defined $_->{url};
  $comic->{$name}->refer($_->{refer}) if defined $_->{refer};
  $comic->{$name}->regexp($_->{regexp}) if defined $_->{regexp};

  print "\turl:    ", $_->{url}, "\n" if defined $_->{url};
  print "\trefer:  ", $_->{refer}, "\n" if defined $_->{refer};
  print "\tregexp: ", $_->{regexp}, "\n" if defined $_->{regexp};
  print "\treal:   ", $comic->{$name}->getRealURL, "\n";
# getAllURLs should really be fixed so that it only has to fetch once.
  print "\t\t", join("\n\t\t", $comic->{$name}->getAllURLs), "\n" if $_->{refer};

  print "ok $num\n";
}
