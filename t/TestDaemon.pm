package TestDaemon;

use HTTP::Daemon;
use HTTP::Status;

sub dotest{
  my $files = shift;
  my $d = new HTTP::Daemon;
  my ($c, $r);

  fork && return $d->sockport();

  for(my $i=1; $i <= $files; $i++){
    $c = $d->accept;

    $r = $c->get_request;
    if($r) {
      if($r->method eq 'GET') {
	$c->send_file_response("t" . $r->url->path);
      } else {
	$c->send_error(RC_FORBIDDEN);
      }
    }
    $c = undef;
    exit;
  }
}

1;
