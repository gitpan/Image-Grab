# Idea of RequestAgent is cut-n-paste from lwp-request
#
# If you know a better way of doing this, please let me know.
#
# We make our own specialization of LWP::UserAgent that asks for
# user/password if document is protected.

package Image::Grab::RequestAgent;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);
require LWP::UserAgent;
@ISA = qw(LWP::UserAgent Exporter);
@EXPORT_OK = qw(
  &new
);
$VERSION='1.0 ';

my @creds = (undef, undef);
my %realm;

sub new { 
  my $self = LWP::UserAgent->new(@_);
  $self->proxy('http', $ENV{http_proxy})
      if defined $ENV{http_proxy};
  $self->proxy('ftp', $ENV{ftp_proxy})
      if defined $ENV{ftp_proxy};
  $self->proxy('gopher', $ENV{gopher_proxy})
      if defined $ENV{gopher_proxy};

  $self;
}

sub register_realm {
  my $self  = shift;
  my $realm = shift;
  my $pass  = shift;
  
  $realm{$realm} = $pass;
}

# A hack ... all my very own.
sub set_password {
  my $self = shift;
  @creds = split('/', $_[0], 2);
}

sub get_basic_credentials  {
  my $self = shift;
  my $realm = $_[0];
  
  if(defined $realm{$realm}) {
    return split('/', $realm{$realm}, 2);
  } else {
    return @creds;
  }
}

1;
