use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Lintilla::Site',
  AUTHOR       => q{Andy Armstrong <andy@hexten.net>},
  VERSION_FROM => 'lib/Lintilla/Site.pm',
  ABSTRACT     => 'Jaded...',
  ( $ExtUtils::MakeMaker::VERSION >= 6.3002
    ? ( 'LICENSE' => 'perl' )
    : () ),
  PL_FILES  => {},
  PREREQ_PM => {
    'Test::More' => 0,
    'YAML'       => 0,
    'Dancer'     => 1.311,
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES    => 'Lintilla-Site-*' },
);
