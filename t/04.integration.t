#!/usr/bin/env perl

use Test::More qw(no_plan);
use Test::Exception;

BEGIN {use_ok('Announcements')};

use MooseX::Declare;

class Test03Announcement extends Announcements::Announcement {
}

my $announcer = Announcements::Announcer->new;
my $runs;

lives_ok { $announcer->when(Test03Announcement => sub { $runs++ }) } "Register with announcer";
lives_ok { $announcer->when(Announcements::Announcement => sub { $runs++ }) } "Again";

is $announcer->subscription_registry->all_subscriptions => 2;

$runs = 0;
$announcer->announce('Test03Announcement');
is $runs => 1;

$runs = 0;
$announcer->announce(Test03Announcement->new);
is $runs => 1;

$runs = 0;
my @args;
$announcer->when(Test03Announcement => sub { @args = @_ });
my $ann = Test03Announcement->new;
$announcer->announce($ann);

is $runs => 1;
is $args[0] => $ann;
is $args[1] => $announcer;

$runs = 0;
$announcer = Announcements::Announcer->new;
$announcer->when([qw(Test03Announcement Announcements::Announcement)],
                 sub { $runs++ });
$announcer->announce('Announcements::Announcement');
is $runs => 2;
