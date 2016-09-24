#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;
use utf8;

use AnyEvent::HTTP;
use JSON::PP qw(decode_json);
use List::MoreUtils qw(uniq);
use List::Util qw(any);
use AnyEvent;

my $consul = $ENV{CONSUL_HTTP_ADDR};
die 'CONSUL_HTTP_ADDR not set' unless $consul;

my %tags = map { ( $_ => 1 ) } grep { defined($_) && length($_) } @ARGV;

my @services;

my $cv = AE::cv;
$cv->begin;
http_get "http://$consul/v1/catalog/datacenters", sub { _datacenters(@_) };
$cv->recv;

say join "\n", uniq sort @services;

exit 0;

sub _datacenters {
  my $resp = shift;

  my $datacenters = decode_json($resp);

  foreach my $dc (@$datacenters) {
    $cv->begin;
    http_get "http://$consul/v1/catalog/services?dc=$dc",
        sub { _services( $dc, @_ ) };
  }

  $cv->end;

  return;
}

sub _services {
  my ( $dc, $resp ) = @_;

  my @names = keys %{ decode_json($resp) };

  unless ( keys %tags ) {
    push @services, @names;
    $cv->end;
    return;
  }

  foreach my $name (@names) {
    $cv->begin;
    http_get "http://$consul/v1/catalog/service/$name?dc=$dc",
        sub { _service( $name, @_ ) };
  }

  $cv->end;

  return;
}

sub _service {
  my ( $name, $resp ) = @_;

  my $data = decode_json($resp);

  if ( any { $tags{$_} } @{ $data->[0]{ServiceTags} } ) {
    push @services, $name;
  }

  $cv->end;

  return;
}
