#!/usr/bin/env perl

use v5.10;

use autodie;
use strict;
use warnings;

use Geo::Coordinates::OSGB qw(grid_to_ll);
use JSON;
use List::Util qw( min max );
use Math::Trig;

use constant MAX_E => 700_000;
use constant MAX_N => 1_300_000;
use constant STEP  => 50_000;
use constant ZOOM  => 17;

use constant XML_PRE => <<EOX;
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>codecFormat</key>
    <string>pxlt</string>
    <key>codecQuality</key>
    <integer>768</integer>
    <key>firstImagePath</key>
    <string>Image_0.tiff</string>
    <key>frameHeight</key>
    <real>1300</real>
    <key>frameWidth</key>
    <real>700</real>
    <key>lastImagePath</key>
    <string>Image_1.tiff</string>
    <key>morphLines</key>
    <array>
EOX

use constant XML_LINE_PRE => <<EOX;
      <dict>
        <key>dissolveEndTime</key>
        <string>1</string>
        <key>dissolveStartTime</key>
        <string>0</string>
        <key>endPointBeginMoveTime</key>
        <string>0</string>
        <key>endPointStopMoveTime</key>
        <string>1</string>
        <key>endPoints</key>
        <array>
EOX

use constant XML_LINE_SEP => <<EOX;
        </array>
        <key>startPointBeginMoveTime</key>
        <string>0</string>
        <key>startPointStopMoveTime</key>
        <string>1</string>
        <key>startPoints</key>
        <array>
EOX

use constant XML_LINE_POST => <<EOX;
        </array>
      </dict>
EOX

use constant XML_POST => <<EOX;
    </array>
  </dict>
</plist>
EOX

my @grid = ();
for ( my $x = 0; $x <= MAX_E; $x += STEP ) {
  my @row = ();
  for ( my $y = 0; $y <= MAX_N; $y += STEP ) {
    my ( $gy, $gx ) = grid_to_gm( $x, $y, ZOOM );
    push @row,
     {in  => { x => $x,  y => MAX_N - $y },
      out => { x => $gx, y => $gy } };
  }
  push @grid, [@row];
}

scale_to_area( \@grid, 'in',  MAX_N / MAX_E );
scale_to_area( \@grid, 'out', MAX_N / MAX_E );

centre( \@grid, 'in' );
centre( \@grid, 'out' );

scale_grid_axis( \@grid, 'in',  'y', MAX_E / MAX_N );
scale_grid_axis( \@grid, 'out', 'y', MAX_E / MAX_N );

offset_grid( \@grid, 'in',  0.5, 0.5 );
offset_grid( \@grid, 'out', 0.5, 0.5 );

print XML_PRE();
print_grid( \@grid );
print_grid( transpose_grid( \@grid ) );
print XML_POST();

sub centre {
  my ( $grid, $key ) = @_;
  my ( $cx, $cy ) = find_centre( $grid, $key );
  offset_grid( $grid, $key, -$cx, -$cy );
}

sub scale_to_area {
  my ( $grid, $key, $out_area ) = @_;
  my $in_area = grid_area( $grid, $key );
  my $scale = 1 / sqrt( $in_area / $out_area );
  scale_grid( $grid, $key, $scale );
}

sub print_grid {
  my $grid = shift;
  for my $line (@$grid) {
    for my $i ( 0 .. $#$line - 1 ) {
      print XML_LINE_PRE();
      print_cell( $line->[$i], 'out' );
      print_cell( $line->[$i], 'in' );
      print XML_LINE_SEP();
      print_cell( $line->[$i + 1], 'out' );
      print_cell( $line->[$i + 1], 'in' );
      print XML_LINE_POST();
    }
  }
}

sub transpose_grid {
  my $grid = shift;
  my $out  = [];
  for my $y ( 0 .. $#grid ) {
    my $row = $grid->[$y];
    for my $x ( 0 .. $#$row ) {
      $out->[$x][$y] = $row->[$x];
    }
  }
  return $out;
}

sub print_cell {
  my ( $cell, $key ) = @_;
  my ( $x, $y ) = @{ $cell->{$key} }{ 'x', 'y' };
  print "          <string>{$x, $y}</string>\n";
}

sub offset_grid {
  my ( $grid, $key, $dx, $dy ) = @_;

  for my $row (@$grid) {
    for my $cell (@$row) {
      $cell->{$key}{x} += $dx;
      $cell->{$key}{y} += $dy;
    }
  }
}

sub find_centre {
  my ( $grid, $key ) = @_;

  my ( $cx, $cy, $count ) = ( 0, 0, 0 );
  for my $row (@$grid) {
    for my $cell (@$row) {
      $cx += $cell->{$key}{x};
      $cy += $cell->{$key}{y};
      $count++;
    }
  }
  return ( $cx / $count, $cy / $count );
}

sub scale_grid_axis {
  my ( $grid, $key, $axis, $scale ) = @_;

  for my $row (@$grid) {
    for my $cell (@$row) {
      $cell->{$key}{$axis} *= $scale;
    }
  }
}

sub scale_grid {
  my ( $grid, $key, $scale ) = @_;
  scale_grid_axis( $grid, $key, 'x', $scale );
  scale_grid_axis( $grid, $key, 'y', $scale );
}

sub grid_area {
  my ( $grid, $key ) = @_;

  my $max_n = @$grid;
  my $max_e = max map { scalar @$_ } @$grid;
  my $area  = 0;

  for my $x ( 0 .. $max_e - 2 ) {
    for my $y ( 0 .. $max_n - 2 ) {
      $area += quad_area(
        $grid->[$y][$x]{$key},
        $grid->[$y][$x + 1]{$key},
        $grid->[$y + 1][$x]{$key},
        $grid->[$y + 1][$x + 1]{$key},
      );
    }
  }
  return $area;
}

sub quad_area {
  my ( $p0, $p1, $p2, $p3 ) = @_;
  return tri_area( $p0, $p1, $p3 ) + tri_area( $p0, $p2, $p3 );
}

sub tri_area {
  my ( $p0, $p1, $p2 ) = @_;
  return
   abs($p0->{x} * ( $p1->{y} - $p2->{y} )
     + $p1->{x} * ( $p2->{y} - $p0->{y} )
     + $p2->{x} * ( $p0->{y} - $p1->{y} ) )
   / 2;
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

# vim:ts=2:sw=2:sts=2:et:ft=perl

