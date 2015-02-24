package Lintilla::Site::Dirt;

use v5.10;

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::Database;

=head1 NAME

Lintilla::Site::Dirt - Dirt subsite

=cut

our $VERSION = '0.1';

prefix '/dirt' => sub {
  get '/home' => sub {
    template 'dirt/index', { title => 'Dirt' }, { layout => 'dirt' };
  };
};

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
