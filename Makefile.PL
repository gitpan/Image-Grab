use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Image::Grab',
    'VERSION_FROM' => 'Grab.pm', # finds $VERSION
    'PREREQ_PM' => {'MD5' => '',
		    'HTTP::Request' => '',
		    'HTML::TreeBuilder' => '',
		    'URI::URL' => '',
		    'LWP::UserAgent' => '',
		   },
);
