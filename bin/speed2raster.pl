#!/usr/bin/env perl

use v5.10;

use autodie;
use strict;
use warnings;

my $src = shift // die "Syntax: $0 <file.asc>\n";
my $grid = load_data($src);
dump_data($grid);

sub dump_data {
  my $grid = shift;
  print join( ' ', @{$_} ), "\n" for @$grid;
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

