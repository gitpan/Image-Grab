package Image::Grab; # -*- cperl -*-

# $Id: Grab.pm,v 1.13 1999/06/09 22:18:30 hershbem Exp $

=head1 NAME

Image::Grab - Perl extension for Grabbing images off the Internet.

=head1 SYNOPSIS

  use Image::Grab;
  $pic = new Image::Grab;

  # The simplest case of a grab
  $pic->url('http://www.example.com/someimage.jpg')
  $pic->grab;

  # How to get at the image
  open(DISPLAY, "| display -");
  print DISPLAY $pic->image;
  close(DISPLAY)

  # A slightly more complicated case
  $pic->url('.*logo.*\.gif');
  $pic->refer('http://www.example.com');
  $pic->grab;

  # Get a weather forecast
  $pic->url('msy.*\.gif');
  $pic->refer('http://www.example.com/weather/msy/content.shtml');
  $pic->grab;

=head1 DESCRIPTION

Image::Grab is a simple way to get images with URLs that change constantly.

The "change constantly" part is important here.  If this module did nothing
but grab an image off the net, then it would be nothing more than a silly
convenience module.  But this module is not silly.

This module was born from a script.  The script was born when a certain 
Comics Syndicate stopped having a static (or even predictable) url for their
comics.  I generalized the code for a friend when he needed to do something
similar.

Hopefully, others will find this module useful as well.

=cut

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;

require MD5;
require HTTP::Request;
require HTML::TreeBuilder;
require URI::URL;
require Image::Grab::RequestAgent;
use POSIX qw(strftime);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
@EXPORT_OK = qw(
  &getRealURL &grab &new
);
$VERSION = '0.9.5';

# %fields, new, AUTOLOAD are from perltoot

my %fields = (
	      cookiefile => undef,
	      cookiejar  => undef,
	      date       => undef,
	      image      => undef,
	      "index"    => undef,
	      md5        => undef,
	      refer      => undef,
	      regexp     => undef,
	      type       => undef,
	      ua         => undef,
	      url        => undef,
	      debug      => undef,
	      do_posix   => undef,
	     );

=head1 Accessor Methods

The following are the accessor methods available for any Image::Grab object.
Accessor methods are used to get or set information for an object.  For
example,

  $img->refer("http://www.example.com");

would set the refer field and

  $img->refer;

would return the information contained in the refer field.

C<refer>, C<regexp>, and C<url> all have POSIX time string expansion
performed on the by getRealURL.  Thus, if you wish to have a '%'
character in your URL, you must put '%%'.

=head2 cookiefile

Where the cookiefile is located.  Set this to the file containing the cookies
if you wish to use the cookie file for the image.

=head2 cookiejar

Usually only used internally.  The cookiejar for the image.

=head2 do_posix

Tells Image::Grab to do POSIX date substitution.  This is off by
default until a bug that I found is fixed.

=head2 date

The date that the image was last updated.  The date is represented in 
the number of seconds from epoch where epoch is January 1, 1970.
This is normally not set by the user.

=head2 image

The actual image.  Usually, you should't try to set this field.

=head2 md5

The md5 sum for the image.  Usually, you shouldn't try to set this
field.

=head2 refer

When you do a C<grab>, this url will be given as the referring URL.
If the C<url> method is not used to specify an image (and the
C<regexp> or C<index> methods are used instead) then the information
from the URL in the refer field will be used to find the image.  For
example, if regexp="mac.*\.gif" and refer="http://www.example.com", then
when a grab is performed, the page at www.example.com is searched to see
if any images on the page match the regular expression.

POSIX time string expansion is performed is do_posix is set.

=head2 type

The type of information.  Usually it will be a MIME type such as "image/jpeg".

=head2 ua

Usually only used internally.  The user agent used to get the image.

=head1 Methods for specifying the image

One of the following should be set to specify the image.  If either
C<regexp> or C<index> are used to specify the image, then C<refer>
must be set to specify the page to be searched for the image.

B<Image::Grab> will the data in the following order: C<url>,
C<regexp>, C<index>.

=head2 index

An integer indicating the image on the page to grab.  For instance,
'1' would find the second image on the page pointed to by the refer.
Used in conjunction with C<regexp>, it specifies which image to grab
that the regular expression matches.

Example:

=over 4

$image->refer("http://www.example.com/index.html");
$image->regexp(1);

=back 4

=head2 regexp

A regular expression that will match the URL of the image.  If
C<index> is not set, then the first image that matches will be used.
If C<index> is set, then the I<n>th image that matches will be used.

POSIX time string expansion is performed if do_posix is set.

Example:

=over 4 

$image->refer("http://www.example.com/index.html");
$image->regexp(".*\.gif");

=back 4

=head2 url

The fully qualified URL of the image.

POSIX time string expansion is performed if do_posix is set.

Example:

=over 4 

$image->url("http://www.example.com/%Y/%m/%d.gif");

=back 4

=cut

sub new {
  my $that  = shift;
  my $class = ref($that) || $that;
  my $self = {
	      _permitted => \%fields,
	      %fields,
	     };

  bless ($self, $class);
  $self->ua(new Image::Grab::RequestAgent);
  return $self;
}

sub AUTOLOAD {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";

  my $name = $AUTOLOAD;
  $name =~ s/.*://;

  unless (exists $self->{_permitted}->{$name} ) {
    croak "Can't access `$name' field in class $type";
  }

  if(@_) {
    my $val = shift;
    carp "$name: $val" if $self->debug;
    return $self->{$name} = $val;
  } elsif (defined $self->{$name}) {
    return $self->{$name};
  }

  return undef;

}

=head1 Other Methods

=head2 realm($realm, $user, $password)

Provides a username/password pair for the realm the image is in.

=cut

# Accessor functions that we have to write.
sub realm {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";

  if($#_ == 2){
    $self->ua->register_realm(shift, shift, shift);
    return 1;
  } 

  croak "usage: realm(\$realm, \$user, \$pass)";
}

=head2 getAllURLs ([$tries])

Returns a list of URLs pointing to images from the page pointed to by
C<refer>.  Of course, C<refer> must be set for this method to be of
any use.

If $tries is specified, then $tries are attempted before giving up.
$tries defaults to 10.

Returns undef if no connection is made in $tries attempts or if the
URL is not of type text/html.

=cut

sub getAllURLs {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";
  my $times = (shift or 10);
  my $req;
  my $count = 0;
  my @link;
  my @now;

  # Need to load Cookie Jar?
  $self->loadCookieJar;

  @now = localtime;
  $self->refer(strftime $self->refer, @now) 
    if defined $self->refer and defined $self->do_posix;
  croak "Need to specify a refer page!" if !defined $self->refer;
  $req = $self->ua->request(new HTTP::Request 'GET', $self->refer);

  # Try $times until successful
  while( (!$req->is_success) && $count < $times){
    $req = $self->ua->request(new HTTP::Request 'GET', $self->refer);
    $count = $count + 1;
  }

  # return failure if we couldn't connect within $times tries
  if($count == $times && !$req->is_success){
    return undef;
  }
  return undef unless $req->content_type eq 'text/html';
  
  # Get the base url
  my $base_url = $req->base;
  
  # Get the img tags out of the document.
  my $parser = new HTML::TreeBuilder;
  $parser->parse($req->content);
  $parser->eof;
  foreach (@{$parser->extract_links(qw(img))}) {
    push @link, URI::URL::url($$_[0])->abs($base_url)->as_string;
  }  

  return @link;
}

=head2 getRealURL ([$tries])

Returns the actual URL of the image specified.  Performs POSIX time
string expansion (see C<strftime>) using the current time if do_posix
is set.

You can use this method to get the URL for an image if that is all you
need.

If $tries is specified, then $tries are attempted before giving up.
$tries defaults to 10.

Returns undef if no connection is made in $tries attempts, if the
refer URL is not of type text/html, or if no image that matches the
specs is found.

If C<url> is given a full URL, then it is returned with POSIX time
string expansion performed if do_posix is set.

=cut

sub getRealURL {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";
  my $times = (shift or 10);
  my $req;
  my $count = 0;
  my @link;
  my @now;

  # Expand any POSIX time excapes
  @now = localtime;

  if(defined $self->url) {
    $self->url(strftime($self->url, @now)) 
      if defined $self->do_posix;
    return $self->url;
  }
  $self->regexp(strftime($self->regexp, @now)) 
    if defined $self->regexp and defined $self->do_posix;

  @link = $self->getAllURLs($times);
  return undef if !defined @link;

  # if this is a relative position tag...
  if($self->regexp || $self->index) {
    my (@match, $re);

    # set index to match fist image
    $self->index(0) if !defined $self->index;
    $re = $self->regexp || '.';
    @match = grep {/$re/} @link;
    # Return the nth 
    return $match[$self->index];
  }

  # only if we fail.
  return undef;
}

=head2 loadCookieJar

Usually used only internally.  Loads up the cookiejar with cookies.

=cut

sub loadCookieJar {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";

  # need to do CookieJar initialization?
  if($self->cookiefile and !-f $self->cookiefile){
    carp $self->cookiefile, " is not a file";
  } elsif ($self->cookiefile and !defined $self->cookiejar) {
    use HTTP::Cookies;

    $self->cookiejar( 
      HTTP::Cookies::Netscape->new( File => $self->cookiefile,
				    AutoSave => 0,
				  ));
    $self->cookiejar->load();
  }

}

=head2 grab ([$tries])

Grab the image.  If the C<url> method is not used to give an absolute
url, then getRealURL is called before the image is fetched.

If $tries is specified, then $tries are attempted before giving up.
$tries defaults to 10.

=cut

sub grab {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";
  my $times = (shift or 1);
  my $req;
  my $count;
  my $rc;

  # need to do CookieJar initialization?
  $self->loadCookieJar;

  # need to find image on page?
  $self->url($self->getRealURL($times));

  # make sure we have a url
  croak "Couldn't determine an absolute URL!\n" unless defined $self->url;
  carp "Fetching URL: ", $self->url if $self->debug;

  # Set it up
  $req = new HTTP::Request 'GET', $self->url;
  $req->push_header('Referer', $self->refer) if defined $self->refer;
  if($self->cookiejar){
    $self->cookiejar->add_cookie_header($req);
  }

  # Knock it down
  $count = 0;
  do{
    $count++;
    $rc = $self->ua->request($req);
  } while($count <= $times and not $rc->is_success);

  # Did we fail?

  return 0 unless $rc->is_success;

  carp "Message: ", $rc->message if $self->debug;

  # save what we got
  $self->image($rc->content);
  $self->date($rc->last_modified);
  $self->md5(MD5->hexhash($self->image));  # This is how we set it initially.
  $self->type($rc->content_type);

  return 1;
}

=head2 grab_new

Not Yet Implemented.  Currently, it acts just like grab.

=cut

sub grab_new {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";
  my $tmp = new $type;

  return $self->grab;
}

1;

__END__

=head1 BUGS

getAllURLs and getRealURL should really be fixed so that they go out
to the 'net only once if they need to.

POSIX date substitution screws up strings longer than 127 chars.  At
least on Perl 5.004_04.

Ummm... I am sure there are others...

=head1 AUTHOR

Mark A. Hershberger <mah@everybody.org>, http://everybody.org/mah

=head1 SEE ALSO

perl(1), strftime(3).

=cut
