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
	      'PREREQ_PM' => {Digest::MD5 => 2.07,
			      HTML::TreeBuilder => 0.51,
			      HTTP::Cookies => 0,
			      Net::FTP => 2.4, # From libwww-perl
			      HTML::HeadParser => 0, # From libwww-perl
			      URI::URL => 1, # From libwww-perl
			      MIME::Base64 => 2.1, # From URI
			      LWP::UserAgent => 0,
			      Socket => 1.3,
			      IO::Socket => 1.05
			     },
	      dist        => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
