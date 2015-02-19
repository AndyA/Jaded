package Lintilla::Site::Admin;

use v5.10;

use Dancer ':syntax';
use Dancer::Plugin::Database;
use Lintilla::DB::Map;
use Lintilla::Tools::Enqueue;

=head1 NAME

Lintilla::Site::Admin - Jaded...

=cut

our $VERSION = '0.1';

sub db { Lintilla::DB::Map->new( dbh => database ) }

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
        colourtools => { url => '/js/colourtools.js' },
        map         => {
          url      => '/js/map.js',
          requires => ['js.jquery', 'js.gmap', 'js.colourtools', 'css.map']
        },
      } }
  );
}

prefix '/map' => sub {
  get '/ws/:ty/:tx/:zoom' => sub {
    forward join( '/',
      '/map/ws',   param('ty'), param('tx'),
      param('ty'), param('tx'), param('zoom') );
  };
  get '/ws/:ty0/:tx0/:ty1/:tx1/:zoom' => sub {
    return db->grid_slice(
      param('ty0'), param('tx0'), param('ty1'), param('tx1'),
      param('zoom')
    );
  };
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
