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

class Test02Announcement extends Announcements::Announcement {
}

sub announcer {
    $_[0]->{announcer} //= Test02Announcer->new;
}

sub make_valid_subscription {
    my($self, $announcement_class, $action, $subscriber) = (@_);

    $announcement_class //= 'Announcements::Announcement';
    $action //= sub { 1 };

    Announcements::Subscription->new(
        action             => $action,
        announcer          => $self->announcer,
        announcement_class => $announcement_class,
        subscriber         => $subscriber // Test02Subscriber->new,
    );
}

sub test_subscriptions_of : Test(1) {
    my $self = shift;
    my $registry = $self->{registry};

    $registry->register($self->make_valid_subscription(undef, undef, 'label1'));
    $registry->register($self->make_valid_subscription('Test02Announcement', undef, 'label2'));

    is +$registry->subscriptions_of('label1') => 1;
}

sub multiple_announcement_classes : Test(2) {
    my $self = shift;
    my $registry = $self->{registry};

    $registry->register($self->make_valid_subscription);
    $registry->register($self->make_valid_subscription('Test02Announcement'));

    is(+($registry->subscriptions_for('Test02Announcement')), 1);
    is(+($registry->subscriptions_for('Announcements::Announcement')), 2);
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
    my @got = @{$registry->subscriptions_for($announcement_class)};
    is +@got, 1;
    is $got[0], $subscription;
}
__PACKAGE__->runtests unless caller;
