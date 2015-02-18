package Lintilla::DB::Map;

use Moose;

=head1 NAME

Lintilla::DB::Map - Map stuff

=cut

has dbh => ( is => 'ro', required => 1 );

sub _empty_grid {
  my ( $self, $height, $width ) = @_;
  return [map [map 0, 0 .. $width - 1], 0 .. $height - 1];
}

sub wind_grid {
  my ( $self, $ty0, $tx0, $ty1, $tx1, $zoom ) = @_;

  my $grid = $self->_empty_grid( $ty1 - $ty0, $tx1 - $tx0 );

  my $data = $self->dbh->selectall_arrayref(
    join( ' ',
      'SELECT ty-? AS y, tx-? AS x, datum FROM wind_grid',
      'WHERE zoom=?',
      'AND ty BETWEEN ? AND ?',
      'AND tx BETWEEN ? AND ?' ),
    { Slice => {} },
    $ty0, $tx0, $zoom, $ty0,
    $ty1 - 1,
    $tx0,
    $tx1 - 1
  );

  for my $tile (@$data) {
    $grid->[$tile->{y}][$tile->{x}] = sprintf '%.2f', $tile->{datum};
  }

  return $grid;
}

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
