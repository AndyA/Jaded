#!/usr/bin/env perl

use v5.10;

use autodie;
use strict;
use warnings;

use Dancer ':script';
use Dancer::Plugin::Database;

@ARGV == 1 or die "Syntax: $0 <level>\n";
my ($lvl) = @ARGV;

print "Creating level $lvl from ", $lvl + 1, "\n";

database->do( 'DELETE FROM wind_grid WHERE zoom=?', {}, $lvl );
database->do(
  join( ' ',
    'INSERT INTO wind_grid (ty, tx, zoom, datum)',
    'SELECT ty DIV 2 AS hty, tx DIV 2 AS htx, ? AS zoom, SUM(datum)/4 AS datum',
    'FROM wind_grid',
    'WHERE zoom=?',
    'GROUP BY htx, hty' ),
  {},
  $lvl,
  $lvl + 1
);

# vim:ts=2:sw=2:sts=2:et:ft=perl

