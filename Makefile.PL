use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	=> 'Image::Grab',
    'VERSION_FROM' => 'Grab.pm', 
    'PREREQ_PM' => {'MD5' => '',
		    'HTTP::Request' => '',
		    'HTML::TreeBuilder' => '',
		    'HTTP::Cookies' => '',
		    'URI::URL' => '',
		    'LWP::UserAgent' => '',
		   },
);
