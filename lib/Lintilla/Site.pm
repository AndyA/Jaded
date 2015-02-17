package Lintilla::Site::Admin;

use v5.10;

use Dancer ':syntax';

#use Dancer::Plugin::Database;
use Lintilla::Tools::Enqueue;

=head1 NAME

Lintilla::Site::Admin - Jaded...

=cut

our $VERSION = '0.1';

sub resources {
  return state $res ||= Lintilla::Tools::Enqueue->new(
    map => {
      css => {},
      js  => { jquery => { url => '/js/jquery-1.11.1.min.js' }, } }
  );
}

get '/' => sub {
  template 'index',
   { title => 'Jaded...', resources => resources->render('js.jquery') };
};

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
