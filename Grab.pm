package Image::Grab;

=head1 NAME

Image::Grab - Perl extension for Grabbing images off the Internet.

=head1 SYNOPSIS

  use Image::Grab;
  $pic = new Image::Grab;

  # The simplest case of a grab
  $pic->url('http://www.url.com/someimage.jpg')
  $pic->grab;

  # How to get at the image
  open(DISPLAY, "| display -");
  print DISPLAY $pic->image;
  close(DISPLAY)

  # A slightly more complicated case
  $pic->url('.*logo.*\.gif');
  $pic->refer('http://www.gtk.com');
  $pic->grab;

  # Get a weather forcast (The regexp finds the image despite the 
  $pic->url('msy.*\.gif');
  $pic->refer('http://www.intellicast.com/weather/msy/content.shtml');
  $pic->grab;

=head1 DESCRIPTION

Image::Grab is a simple way to get images with URLs that change constantly.

=cut

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;

require MD5;
require HTTP::Request;
require HTML::TreeBuilder;
require URI::URL;
require Image::Grab::RequestAgent;

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
@EXPORT_OK = qw(
  &getRealURL &grab &new
);
$VERSION = '0.9';

# for now, this is how we find which "urls" are really urls.
my $urlregexp="^http://";

# %fields, new, AUTOLOAD are from perltoot

my %fields = (
	      refer   => undef,
	      url     => undef,
	      date    => undef,
	      md5     => undef,
	      cookiefile => undef,
              cookiejar  => undef,
	      image   => undef,
	      type    => undef,
	      ua      => undef,
	     );

=head1 Accessor Methods

The following are the accessor methods availible for any Image::Grab object.
Accessor methods are used to get or set information for an object.  For
example,

  $img->refer("http://www.yahoo.com");

would set the refer field and

  $img->refer;

would return the information contained in the refer field.

=head2 refer

When you do a grab, this url will be given as the referring URL.  
If the information contained in the 'url' property is not a URL, 
then the information from the URL in the refer field will be used to
find the image.  For example, if url="mac.*\.gif" and 
refer="http://www.yahoo.com", then when a grab is performed, the page at 
www.yahoo.com is searched to see if any images on the page match the
regular expression in url.  The first one that matches is grabbed.

=head2 url

The url that is ultimatly grabbed.  This should be set before any grab 
is done.  It can be a straight url, a regular expression, or an index
for the image.  For an example of a regular expression, see the section
on refer.  Indexes begin with a pound sign ("#") and are followed by a
number that indicates the image on the page.  For instance, "#2" would 
find the second image on the page pointed to by the refer.

=head2 date

The date that the image was last updated.  The date is represented in 
the number of seconds from epoch where epoch is January 1, 1970.

=head2 md5

The md5 sum for the image.  Usually, you shouldn\'t try to set this
field.

=head2 type

The type of information.  Usually it will be a MIME type such as "image/jpeg".

=head2 cookiefile

Where the cookiefile is located.  Set this to the file containing the cookies
if you wish to use the cookie file for the image.

=head2 cookiejar

Usually only used internally.  The cookiejar for the image.

=head2 image

The actual image.  Usually, you should\'t try to set this field.

=head2 ua

Usually only used internally.  The user agent used to get the image.

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

  if (@_) {
    return $self->{$name} = shift;
  } else {
    return $self->{$name};
  } 
}

=head1 Other Methods

=head2 realm($user, $password)

Provides a username/password pair for the realm the image is in.

=cut

# Accessor functions that we have to write.
sub realm {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";

  if(@_){
    my ($user, $pass) = @_;

    $self->ua->register_realm($user, $pass);
  }

  return 1;
}

=head2 getRealURL

Returns the actual URL of the image.  This method is called internally to
determine the URL of the image if the information contained in the URL field
is not a url.

You can use this method to get the URL for an image if that is all you need.

=cut

sub getRealURL {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";
  my $times = (shift or 10);
  my $req = $self->ua->request(new HTTP::Request 'GET', $self->refer);
  my $count = 0;
  my @link;
  
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
    push @link, $$_[0];
  }  

  # if this is a relative position tag...
  if($self->url =~ /^\#/) {
     my $n = substr($self->url, 1) - 1;

     # Return the nth 
     return URI::URL::url($link[$n])->abs($base_url)->as_string;
   }

  # we can match an image against our regular expression...
  foreach (@link){
    my $patt = $self->url;

    return URI::URL::url($_)->abs($base_url)->as_string if /$patt/;
  }

  # only if we fail.
  return undef;
}

=head2 grab

Grab the image.  url must contain an actual URL or information that can produce
a URL before this method can be used.  If url does not contain a URL, then
getRealURL is called before the image is fetched.

=cut

sub grab {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";
  my $times = (shift or 10);
  my $req;
  my $count;
  my $rc;

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

  # need to find image on page?
  if(not ($self->url =~ /$urlregexp/i) ){
    $self->url($self->getRealURL($times));
  }

  # make sure we have a url
  return 0 unless defined $self->url;

  # Set it up
  $req = new HTTP::Request 'GET', $self->url;
  $req->push_header('Referer', $self->refer);
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

# Autoload methods go after =cut, and are processed by the autosplit program.

1;

__END__

=head1 BUGS

It only understands as URLs strings that begin with "http://".

Perhaps URL should not be so overloaded.  Perhaps I should have 'regexp' and
'index' accessor methods.

Ummm... I am sure there are others...

=head1 AUTHOR

Mark 'Hex' Hershberger <mah@eecs.tulane.edu>

=head1 SEE ALSO

perl(1).

=cut
