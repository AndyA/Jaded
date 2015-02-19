#!/usr/bin/env perl

use v5.10;

use autodie;
use strict;
use warnings;

use Data::Dumper;
use GD;
use List::Util qw( min max );
use Path::Class;

use constant HEAT_MIN => 4;
use constant HEAT_MAX => 12;

2 == @ARGV || die "Syntax: $0 <rasterfile> <out.png>\n";
my ( $src, $png ) = @ARGV;

draw_raster( $src, $png );

sub draw_raster {
  my ( $in, $out ) = @_;
  my $grid  = load_raster($in);
  my $max_n = @$grid;
  my $max_e = max map { scalar @$_ } @$grid;
  my @vals  = map { @$_ } @$grid;
  my $min_v = min(@vals);
  my $max_v = max(@vals);

  print "$max_e, $max_n, $min_v, $max_v\n";

  my $img = GD::Image->newTrueColor( $max_e, $max_n );
  $img->alphaBlending(0);
  $img->saveAlpha(1);

  for my $nn ( 0 .. $max_n - 1 ) {
    my $row = $grid->[$max_n - 1 - $nn];
    for my $ee ( 0 .. $max_e - 1 ) {
      my $dat = $row->[$ee];
      my $pv  = ( $dat - HEAT_MIN ) / ( HEAT_MAX - HEAT_MIN );
      my $av  = $dat < HEAT_MIN ? 127 : 0;
      my @rgb = heat_colour($pv);
      my $co  = $img->colorAllocateAlpha( @rgb, $av );
      $img->setPixel( $ee, $nn, $co );
    }
  }

  print { file($out)->openw } $img->png;
}

sub hsv2rgb {
  my ( $h, $s, $v ) = @_;
  my ( $r, $g, $b );

  while ( $h < 0 ) { $h += 360; }
  while ( $h >= 360 ) { $h -= 360; }

  $h /= 60;
  my $i = int $h;
  my $f = $h - $i;
  my $p = $v * ( 1 - $s );
  my $q = $v * ( 1 - $s * $f );
  my $t = $v * ( 1 - $s * ( 1 - $f ) );

  if    ( $i == 0 ) { $r = $v; $g = $t; $b = $p; }
  elsif ( $i == 1 ) { $r = $q; $g = $v; $b = $p; }
  elsif ( $i == 2 ) { $r = $p; $g = $v; $b = $t; }
  elsif ( $i == 3 ) { $r = $p; $g = $q; $b = $v; }
  elsif ( $i == 4 ) { $r = $t; $g = $p; $b = $v; }
  else              { $r = $v; $g = $p; $b = $q; }

  return map { int( $_ * 255 ) } ( $r, $g, $b );
}

sub heat_colour {
  my $v = shift;

  my $vv = max( 0, min( $v, 1 ) )**0.5;
  my @hsv = ( 360 * ( 1 - $vv ) * 0.9, 1, $vv );
  return hsv2rgb(@hsv);
}

sub load_raster {
  my $file = shift;
  my $grid = [];
  open my $fh, '<', $file;
  while (<$fh>) {
    chomp;
    push @$grid, [split /\s+/, $_];
  }
  return $grid;
}

# vim:ts=2:sw=2:sts=2:et:ft=perl
