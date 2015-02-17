#!perl

use strict;
use warnings;
use Test::More;

use Lintilla::Tools::Enqueue;

{
  my $enq = Lintilla::Tools::Enqueue->new(
    map => {
      css => {
        admin2 => { url => '/admin2/css/admin2.css' },
        jquery_labeledslider =>
         { url => '/admin2/css/jquery.ui.labeledslider.css' },
        fa        => { url => '/css/font-awesome/css/font-awesome.min.css' },
        jquery_ui => { url => '/css/jquery-ui.min.css' },
      },
      js => {
        uri       => { url => '/admin2/js/URI.js' },
        spin      => { url => '/admin2/js/spin.min.js' },
        jquery    => { url => '/js/jquery-1.11.1.min.js' },
        diff_lcs  => { url => '/admin2/js/diff-lcs.js' },
        jquery_ui => {
          url      => '/js/jquery-ui.min.js',
          requires => ['css.jquery_ui', 'js.jquery']
        },
        jquery_hotkeys => {
          url      => '/admin2/js/jquery.hotkeys.js',
          requires => ['js.jquery']
        },
        jquery_labeledslider => {
          url      => '/admin2/js/jquery.ui.labeledslider.min.js',
          requires => ['css.jquery_labeledslider', 'js.jquery_ui']
        },
        util => {
          url      => '/admin2/js/util.js',
          requires => ['js.jquery']
        },
        scroller => {
          url      => '/admin2/js/scroller.js',
          requires => ['js.jquery']
        },
        progress => {
          url      => '/admin2/js/progress.js',
          requires => ['js.spin', 'js.jquery']
        },
        datawatcher => {
          url      => '/admin2/js/datawatcher.js',
          requires => ['js.jquery']
        },
        ev => {
          url      => '/admin2/js/ev.js',
          requires => ['js.jquery']
        },
        htmldiff => {
          url      => '/admin2/js/htmldiff.js',
          requires => ['js.jquery']
        },
        programme => {
          url      => '/admin2/js/programme.js',
          requires => ['js.jquery']
        },
        versions => {
          url => '/admin2/js/versions.js',
          requires =>
           ['js.jquery', 'js.jquery_labeledslider', 'js.textdiff', 'js.htmldiff']
        },
        textdiff => {
          url      => '/admin2/js/textdiff.js',
          requires => ['js.diff_lcs']
        },
        app => {
          url      => '/admin2/js/app.js',
          requires => ['js.jquery']
        },
        adminapp => {
          url      => '/admin2/js/adminapp.js',
          requires => ['js.jquery', 'js.datawatcher', 'js.app']
        },
        wysihtml5_parser_rules =>
         { url => '/admin2/js/wysihtml5/parser_rules/advanced.js' },
        wysihtml5 => {
          url      => '/admin2/js/wysihtml5/wysihtml5-0.3.0.min.js',
          requires => ['js.wysihtml5_parser_rules']
        },
        approve => {
          url      => '/admin2/js/approve.js',
          requires => [
            'css.admin2',  'js.jquery', 'js.adminapp', 'js.programme',
            'js.versions', 'js.util',   'js.progress', 'js.uri',
            'js.scroller', 'js.jquery_hotkeys',
          ]
        },
      } }
  );
  isa_ok $enq, 'Lintilla::Tools::Enqueue';
  is_deeply $enq->expand, [], 'empty queue';
  is_deeply $enq->expand('js.approve'),
   ['css.admin2',               'js.jquery',
    'js.datawatcher',           'js.app',
    'js.adminapp',              'js.programme',
    'css.jquery_labeledslider', 'css.jquery_ui',
    'js.jquery_ui',             'js.jquery_labeledslider',
    'js.diff_lcs',              'js.textdiff',
    'js.htmldiff',              'js.versions',
    'js.util',                  'js.spin',
    'js.progress',              'js.uri',
    'js.scroller',              'js.jquery_hotkeys',
    'js.approve'
   ],
   'scheduled approve';
  #  diag $enq->render;
}

{
  my $root = Lintilla::Tools::Enqueue->new(
    map => {
      css => {
        fa        => { url => '/css/font-awesome/css/font-awesome.min.css' },
        jquery_ui => { url => '/css/jquery-ui.min.css' },
      },
      js => {
        jquery    => { url => '/js/jquery-1.11.1.min.js' },
        jquery_ui => {
          url      => '/js/jquery-ui.min.js',
          requires => ['css.jquery_ui', 'js.jquery']
        },
      } }
  );
  my $enq = Lintilla::Tools::Enqueue->new(
    inherit => $root,
    map     => {
      css => {
        admin2 => { url => '/admin2/css/admin2.css' },
        jquery_labeledslider =>
         { url => '/admin2/css/jquery.ui.labeledslider.css' },
      },
      js => {
        uri            => { url => '/admin2/js/URI.js' },
        spin           => { url => '/admin2/js/spin.min.js' },
        diff_lcs       => { url => '/admin2/js/diff-lcs.js' },
        jquery_hotkeys => {
          url      => '/admin2/js/jquery.hotkeys.js',
          requires => ['js.jquery']
        },
        jquery_labeledslider => {
          url      => '/admin2/js/jquery.ui.labeledslider.min.js',
          requires => ['css.jquery_labeledslider', 'js.jquery_ui']
        },
        util => {
          url      => '/admin2/js/util.js',
          requires => ['js.jquery']
        },
        scroller => {
          url      => '/admin2/js/scroller.js',
          requires => ['js.jquery']
        },
        progress => {
          url      => '/admin2/js/progress.js',
          requires => ['js.spin', 'js.jquery']
        },
        datawatcher => {
          url      => '/admin2/js/datawatcher.js',
          requires => ['js.jquery']
        },
        ev => {
          url      => '/admin2/js/ev.js',
          requires => ['js.jquery']
        },
        htmldiff => {
          url      => '/admin2/js/htmldiff.js',
          requires => ['js.jquery']
        },
        programme => {
          url      => '/admin2/js/programme.js',
          requires => ['js.jquery']
        },
        versions => {
          url => '/admin2/js/versions.js',
          requires =>
           ['js.jquery', 'js.jquery_labeledslider', 'js.textdiff', 'js.htmldiff']
        },
        textdiff => {
          url      => '/admin2/js/textdiff.js',
          requires => ['js.diff_lcs']
        },
        app => {
          url      => '/admin2/js/app.js',
          requires => ['js.jquery']
        },
        adminapp => {
          url      => '/admin2/js/adminapp.js',
          requires => ['js.jquery', 'js.datawatcher', 'js.app']
        },
        wysihtml5_parser_rules =>
         { url => '/admin2/js/wysihtml5/parser_rules/advanced.js' },
        wysihtml5 => {
          url      => '/admin2/js/wysihtml5/wysihtml5-0.3.0.min.js',
          requires => ['js.wysihtml5_parser_rules']
        },
        approve => {
          url      => '/admin2/js/approve.js',
          requires => [
            'css.admin2',  'js.jquery', 'js.adminapp', 'js.programme',
            'js.versions', 'js.util',   'js.progress', 'js.uri',
            'js.scroller', 'js.jquery_hotkeys',
          ]
        },
      } }
  );
  isa_ok $enq, 'Lintilla::Tools::Enqueue';
  is_deeply $enq->expand, [], 'empty queue';
  is_deeply $enq->expand('js.approve'),
   ['css.admin2',               'js.jquery',
    'js.datawatcher',           'js.app',
    'js.adminapp',              'js.programme',
    'css.jquery_labeledslider', 'css.jquery_ui',
    'js.jquery_ui',             'js.jquery_labeledslider',
    'js.diff_lcs',              'js.textdiff',
    'js.htmldiff',              'js.versions',
    'js.util',                  'js.spin',
    'js.progress',              'js.uri',
    'js.scroller',              'js.jquery_hotkeys',
    'js.approve'
   ],
   'scheduled approve';
}

done_testing();

# vim:ts=2:sw=2:et:ft=perl

