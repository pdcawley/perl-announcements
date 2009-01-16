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

sub test_registering_an_empty_subscription_should_croak : Test {
    my $registry = shift->{registry};

    eval { $registry->register(Announcements::Subscription->new) };
    isa_ok($@ => 'Announcements::IncompleteSubscriptionError');
}

use MooseX::Declare;
class Test02Announcer {
}

class Test02Subscriber {
}

sub test_registering_a_populated_subscription : Test(2) {
    my $self = shift;
    my $registry = $self->{registry};

    my $announcer = Test02Announcer->new;
    my $announcement_class = 'Announcements::Announcement';
    my $subscriber = Test02Subscriber->new;

    my $subscription = Announcements::Subscription->new(
        action => sub { 1 },
        announcer => $announcer,
        announcement_class => $announcement_class,
        subscriber => $subscriber,
    );

    $registry->register($subscription);
    my @got = $registry->subscriptions_for($announcement_class);
    is scalar(@got), 1;
    is $got[0], $subscription;
}
__PACKAGE__->runtests unless caller;
