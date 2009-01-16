#!/usr/bin/env perl

package SubscriptionCollectionTest;
use strict;
use warnings;

use base qw(Test::Class);
use Test::More;

use feature ':5.10';

use Announcements;

sub make_announcer : Test(setup) {
    shift->{announcer} = Announcements::Announcer->new();
}

sub test_creation : Test(1) {
    isa_ok(Announcements::SubscriptionCollection->new() => 'Announcements::SubscriptionCollection');
}

sub test_extension : Test(2) {
    my $sub = Announcements::Subscription->new;
    my $set =  Announcements::SubscriptionCollection->new()
            << $sub;
    isa_ok($set => 'Announcements::SubscriptionCollection');
    ok $set->contains($sub);
}

sub test_creation_from_subscriptions : Test(1) {
    my $set = Announcements::Subscription->new() << Announcements::Subscription->new();

    isa_ok($set => 'Announcements::SubscriptionCollection');
}


__PACKAGE__->runtests unless caller;
