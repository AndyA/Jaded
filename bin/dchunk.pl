#!/usr/bin/env perl

use v5.10;

use autodie;
use strict;
use warnings;

use constant BATCH => 100;
use constant ZOOM  => 17;

use constant INSERT =>
 'INSERT INTO wind_grid (ty, tx, datum, zoom) VALUES';

my @buf = ();

sub flush {
  return unless @buf;
  print INSERT, join( ', ', map "($_)", @buf ), ";\n";
  @buf = ();
}

while (<>) {
  chomp;
  next if /^\s*#/;
  push @buf, join( ', ', $_, ZOOM );
  flush() if @buf > BATCH;
}

flush();

# vim:ts=2:sw=2:sts=2:et:ft=perl

