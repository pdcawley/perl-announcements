#!/usr/bin/env perl

package SubscriptionCollectionTest;
use strict;
use warnings;

use base qw(Test::Class);
use Test::More;

use Announcements;

sub make_announcer : Test(setup) {
    shift->{announcer} = Announcements::Announcer->new();
}

sub test_creation : Test(1) {
    isa_ok(Announcements::SubscriptionCollection->new() => 'Announcements::SubscriptionCollection');
}

__PACKAGE__->runtests unless caller;
