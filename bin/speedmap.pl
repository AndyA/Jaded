#!/usr/bin/env perl

use v5.10;

use autodie;
use strict;
use warnings;

use GD;
use List::Util qw( min max );
use Math::Trig;
use Path::Class;
use Memoize;

use constant DATA => 'speed45.asc';
use constant IMG  => 'speed45.png';

memoize 'heat_norm_rgb';

draw_wind( DATA, IMG );

sub draw_wind {
  my ( $in, $out ) = @_;
  my $grid  = load_data(DATA);
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
      my $pv  = int( $dat * 255 / $max_v );
      my $av  = $dat == 0 ? 127 : 0;
      my $co  = $img->colorAllocateAlpha( $pv, $pv, $pv, $av );
#      my $co = $img->colorAllocateAlpha( heat_norm_rgb( $dat / $max_v ), $av );
      $img->setPixel( $ee, $nn, $co );
    }
  }

  print { file($out)->openw } $img->png;
}

sub rad { $_[0] * pi / 180.0 }

sub heat_scale_rgb {
  my $v = max( 0, min( $_[0], 1 ) ) * 240;
  ( cos( rad( $v + 240 ) ), cos( rad( $v + 120 ) ), cos( rad($v) ) );
}

sub heat_norm_rgb {
  my @rgb   = heat_scale_rgb(@_);
  my $min   = min(@rgb);
  my $scale = max(@rgb) - $min;
  return map { int( ( $_ - $min ) * 255 / $scale ) } @rgb;
}

sub load_data {
  my $file = shift;
  my $grid = [];
  open my $fh, '<', $file;
  while (<$fh>) {
    chomp;
    next unless /^\(/;
    my ( $loc, @dat ) = split /\s*;\s*/;
    die unless $loc =~ m{^\(\s*(\d+)\s*,\s*(\d+)\)$};
    my ( $e, $n ) = ( $1, $2 );
    @{ $grid->[$n] //= [] }[$e .. $e + $#dat] = @dat;
  }
  return $grid;
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

