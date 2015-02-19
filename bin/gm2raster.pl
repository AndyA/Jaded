#!/usr/bin/env perl

use v5.10;

use autodie;
use strict;
use warnings;

use Dancer ':script';
use Dancer::Plugin::Database;
use List::Util qw( min max );

my ($zoom) = @ARGV;

unless ( defined $zoom ) {
  ($zoom) = database->selectrow_array('SELECT MAX(zoom) FROM wind_grid');
}

print STDERR "# Rasterising zoom level $zoom\n";

my ( $min_tx, $min_ty )
 = database->selectrow_array(
  'SELECT MIN(tx), MIN(ty) FROM wind_grid WHERE zoom=?',
  {}, $zoom );

my $sth = database->prepare(
  'SELECT * FROM wind_grid WHERE zoom=? ORDER BY tx, ty');
$sth->execute($zoom);
my @grid = ();
while ( my $row = $sth->fetchrow_hashref ) {
  $grid[$row->{ty} - $min_ty][$row->{tx} - $min_tx] = $row->{datum};
}

$_ //= [] for @grid;
my $width = max map { scalar @$_ } @grid;
$_->[$width - 1] //= 0 for @grid;
print STDERR "# Width $width\n";
dump_data( [reverse @grid] );

sub dump_data {
  my $grid = shift;
  print join( ' ', map { $_ // 0 } @{$_} ), "\n" for @$grid;
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

