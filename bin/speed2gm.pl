#!/usr/bin/env perl

use v5.10;

use autodie;
use strict;
use warnings;

use Geo::Coordinates::OSGB qw(ll_to_grid grid_to_ll);
use List::Util qw( min max );
use Math::Trig;

use constant DATA      => 'data/speed45.asc';
use constant GRID_SIZE => 1000;                 # metres
use constant TILE_SIZE => 8;                    # 2 ** N

#my $zm = 2;
#my @ll = ( 57, -2 );
#my @pp = ll_to_gm( @ll, $zm );
#print join( '; ',
#  join( ', ', @ll ),
#  join( ', ', @pp ),
#  join( ', ', gm_to_ll( @pp, $zm ) ) ),
# "\n";

#exit;

convert_grid( DATA, GRID_SIZE, TILE_SIZE );

sub convert_grid {
  my ( $in, $gsz, $tsz ) = @_;
  my $grid  = load_data($in);
  my $max_n = @$grid;
  my $max_e = max map { scalar @$_ } @$grid;
  my $tsq   = 2**$tsz;

  my ( $zoom, $min_lat, $min_lon, $max_lat, $max_lon )
   = calc_range( $max_e, $max_n, $gsz );

  $min_lat = int( $min_lat / $tsq );
  $max_lat = int( $max_lat / $tsq );
  $min_lon = int( $min_lon / $tsq );
  $max_lon = int( $max_lon / $tsq );

  printf "zoom: %d, [%12.3f, %12.3f] [%12.3f, %12.3f]\n", $zoom, $min_lat,
   $min_lon, $max_lat, $max_lon;

  my $gs = make_grid_sample( $grid, $gsz, $max_e, $max_n );

  my $d_lat = ( $max_lat - $min_lat ) / 80;
  my $d_lon = ( $max_lon - $min_lon ) / 20;

  for ( my $lat = $min_lat; $lat < $max_lat; $lat += $d_lat ) {
    for ( my $lon = $min_lon; $lon < $max_lon; $lon += $d_lon ) {
      my ( $e, $n ) = gm_to_grid( $lat, $lon, $zoom - $tsz );
      my $gv = $gs->( $e, $n );
      if ($gv) { printf " %5.2f", $gv }
      else     { print '      ' }
    }
    print "\n";
  }
}

sub make_grid_sample {
  my ( $grid, $gsz, $max_e, $max_n ) = @_;

  my $grid_get = sub {
    my ( $e, $n ) = @_;
    return 0 if $e < 0 || $e >= $max_e || $n < 0 || $n >= $max_n;
    return $grid->[$n][$e];
  };

  return sub {
    my ( $e, $n ) = @_;
    return 0 if $e < $gsz / 2 || $n < $gsz / 2;
    my $ge = int( ( $e - $gsz / 2 ) / $gsz );
    my $gn = int( ( $n - $gsz / 2 ) / $gsz );
    my $vse = $grid_get->( $ge,     $gn );
    my $vsw = $grid_get->( $ge + 1, $gn );
    my $vne = $grid_get->( $ge,     $gn + 1 );
    my $vnw = $grid_get->( $ge + 1, $gn + 1 );
    my $ec  = $e / $gsz - $ge - 0.5;
    my $nc  = $n / $gsz - $gn - 0.5;
    die "$e, $n -> $ge, $gn -> $ec $nc"
     if $ec < 0 || $ec >= 1 || $nc < 0 || $nc >= 1;
    my $vs = $vse * ( 1 - $ec ) + $vsw * $ec;
    my $vn = $vne * ( 1 - $ec ) + $vnw * $ec;
    return $vs * ( 1 - $nc ) + $vn * $nc;
  };
}

sub grid_sample {
  my ( $gg, $e, $n ) = @_;
}

sub calc_range {
  my ( $max_e, $max_n, $gsz ) = @_;

  for my $zoom ( 0 .. 30 ) {
    my ( $min_lat, $min_lon, $max_lat, $max_lon )
     = gm_bb( 0, 0, $max_e * $gsz, $max_n * $gsz, $zoom );
    my $lat = $max_lat - $min_lat;
    my $lon = $max_lon - $min_lon;
    return ( $zoom, $min_lat, $min_lon, $max_lat, $max_lon )
     if $lat > $max_e * 2 && $lon > $max_n * 2;
  }
  die;
}

sub gm_bb {
  my ( $min_e, $min_n, $max_e, $max_n, $zoom ) = @_;
  my ( @lat, @lon );
  for my $e ( $min_e, $max_e ) {
    for my $n ( $min_n, $max_n ) {
      my ( $lat, $lon ) = grid_to_gm( $e, $n, $zoom );
      push @lat, $lat;
      push @lon, $lon;
    }
  }
  return ( min(@lat), min(@lon), max(@lat), max(@lon) );
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

sub gm_to_grid { ll_to_grid( gm_to_ll(@_) ) }

sub grid_to_gm {
  my ( $e, $n, $zoom ) = @_;
  return ll_to_gm( grid_to_ll( $e, $n ), $zoom );
}

sub gm_to_ll {
  my ( $py, $px, $zoom ) = @_;

  my $scale = 2**$zoom * 128;
  my $lon = 180 * ( $px / $scale - 1 );

  my ( $min_lat, $max_lat, $lat ) = ( -90, 90 );
  while () {
    #    print "$min_lat, $max_lat\n";
    $lat = ( $max_lat + $min_lat ) / 2;
    last if $max_lat - $min_lat < 0.0000000001;
    my $sin_phi = sin( $lat * pi / 180 );
    my $cpy     = $scale
     * ( 1 - 0.5 * log( ( 1 + $sin_phi ) / ( 1 - $sin_phi ) ) / pi );
    if   ( $cpy > $py ) { $min_lat = $lat }
    else                { $max_lat = $lat }
  }

  return ( $lat, $lon );
}

sub ll_to_gm {
  my ( $lat, $lon, $zoom ) = @_;

  my $scale   = 2**$zoom * 128;
  my $sin_phi = sin( $lat * pi / 180 );

  return (
    $scale * ( 1 - 0.5 * log( ( 1 + $sin_phi ) / ( 1 - $sin_phi ) ) / pi ),
    $scale * ( $lon / 180 + 1 ) );
}

sub _ll_to_gm {
  my ( $lat, $lon, $zoom ) = @_;
  my $scale = 2**$zoom;
  return (
    ( 90 - $lat ) * $scale * 256 / 180,
    ( $lon + 180 ) * $scale * 256 / 360,
  );
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

