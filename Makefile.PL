use ExtUtils::MakeMaker;

$s = prompt("`make test' needs a net connection.  Test? ", "N");
unless (lc($s) eq 'n') {
  open(T, '>t/test');
  print T "t";
  close T;
}

WriteMakefile(
	      'NAME'	=> 'Image::Grab',
	      'AUTHOR'  => 'Mark A. Hershberger, mah@everybody.org',
	      'VERSION_FROM' => 'lib/Image/Grab.pm',
	      'PREREQ_PM' => {HTML::TreeBuilder => 0.51,
			      HTTP::Cookies => 0,
			      URI::URL => 1,
			      LWP::UserAgent => 0,
			     },
	      dist        => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
