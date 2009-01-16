use strict;
use warnings;

use inc::Module::Install 0.77;

name 'Announcements';
all_from 'lib/Announcements.pm';
requires 'Test::More';
requires 'MooseX::Declare';
requires 'MooseX::Method::Signatures' => '0.06';
requires 'Test::Class';
requires 'version';

repository 'git:://github.com/pdcawley/perl-announcements.git';

WriteAll;
