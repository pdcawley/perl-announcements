#!/usr/bin/env perl

package SubscriptionRegistryTest;
use strict;
use warnings;

use base qw(Test::Class);
use Test::More;

use Announcements::SubscriptionRegistry;

sub make_registry : Test(setup) {
    shift->{registry} = Announcements::SubscriptionRegistry->new;
}

sub registering_an_empty_subscription_should_croak : Test {
    my $registry = shift->{registry};

    eval { $registry->register(Announcements::Subscription->new) };
    isa_ok($@ => 'Announcements::IncompleteSubscriptionError');
}

__PACKAGE__->runtests unless caller;
