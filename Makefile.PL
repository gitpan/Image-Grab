use ExtUtils::MakeMaker qw(prompt WriteMakefile);

$r = prompt("Do you want to perform tests\nthat require an active Network connection?", "N");
unless(lc(substr($r, 0, 1)) eq 'y' && open(C, ">t/have_network")) {
  print C "ok";
  close C;
}

WriteMakefile(
    'NAME'	=> 'Image::Grab',
    'VERSION_FROM' => 'lib/Image/Grab.pm',
    'PREREQ_PM' => {Digest::MD5 => 2.07,
		    HTML::TreeBuilder => 0.51,
		    HTTP::Cookies => 0,
		    HTML::HeadParser => 0, # From libwww-perl
		    URI::URL => 1, # From libwww-perl
		    LWP::UserAgent => 0,
		   },
    dist        => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);

unless(-f "README") {
  use Pod::Text;
  `stty cols 80`;		# BETTER WAY?
  open(R, ">README") || die "No README written";
  *STDOUT = *R;
  pod2text("README.pod");
  close(R);
}
