use ExtUtils::MakeMaker qw(prompt WriteMakefile);

$r = prompt("Do you want to perform tests\nthat require an active Network connection?", "N");
unless(lc(substr($r, 0, 1)) eq 'y' && open(C, ">t/have_network")) {
  print C "ok";
  close C;
}

sub MY::postamble {
q{
.PHONY: release

README: README.pod
	pod2text -w 80 README.pod > README

index.html: lib/Image/Grab.pm
	pod2html lib/Image/Grab.pm > index.html

ChangeLog.html: ChangeLog
	emacs -q --no-site-files '(htmlize-file "ChangeLog")'

release: README index.html ChangeLog.html $(DISTVNAME).tar$(SUFFIX)
	scp index.html everybody.org:public_html/hacks/perl/Image-Grab/Image-Grab-$(VERSION).html
	scp ChangeLog.html everybody.org:public_html/hacks/perl/Image-Grab/
	scp $(DISTVNAME).tar.$(SUFFIX) everybody.org:public_html/hacks/perl/Image-Grab/
	ssh everybody.org ln -sf $(DISTVNAME).tar.$(SUFFIX) public_html/hacks/perl/Image-Grab/Image-Grab.tar.gz
	stty -echo
	perl -e 'use LWP::UserAgent;                                     \
		use HTTP::Request::Common qw(POST);                     \
		$$ua = LWP::UserAgent->new;                              \
		print "Password: "; \
		$$pass = <STDIN>; print "\n"; sub LWP::UserAgent::get_basic_credentials {("MAHEX", $$pass)}; \
		my $$req = $$ua->request(POST "https://pause.perl.org/pause/authenquery", \
			[ pause99_add_uri_uri =>                  \
			q{http://mah.everybody.org/hacks/perl/Image-Grab-$(VERSION).tar.gz}, \
			submit => q{SUBMIT_pause99_add_uri_uri} ]); \
		print $$req->as_string;'
	stty echo
}}


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

