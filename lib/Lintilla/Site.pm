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
      css => { map => { url => '/css/map.css' }, },
      js  => {
        jquery => { url => '/js/jquery-1.11.1.min.js' },
        gmap   => {
             url => 'https://maps.googleapis.com/maps/api/js?key='
           . config->{gmap_api_key}
        },
        map => {
          url      => '/js/map.js',
          requires => ['js.jquery', 'js.gmap', 'css.map']
        },
      } }
  );
}

prefix '/map' => sub {
  get '/**' => sub { forward '/map' };
};

get '/map' => sub {
  template 'map',
   { title => 'A Map', resources => resources->render('js.map') };
};

get '/' => sub {
  template 'index',
   { title => 'Jaded...', resources => resources->render('js.jquery') };
};

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
