#!/usr/bin/env perl

package AnnouncerTest;
use strict;
use warnings;

use Announcements;

use MooseX::Declare;
class Announcement1 extends Announcements::Announcement {
    has 'message' => (is => 'rw', isa => 'Str');
}

class Announcement2 extends Announcements::Announcement {
}

class Subscriber {
}

use base qw(Test::Class);
use Test::More;

use feature ':5.10';

sub make_announcer {
    shift->{announcer} = Announcements::Announcer->new;
}

sub announcer {
    shift->{announcer}
}

sub test_when_with_single_class : Test(2) {
    my $self = shift;
    my $announcer = $self->make_announcer;

    $announcer->when('Announcement1', sub { });

    is +$announcer->subscription_registry->all_subscriptions => 1;
    is $announcer->subscription_registry->all_subscriptions->[0]->announcement_class => 'Announcement1';
}

sub test_when_with_for : Test(2) {
    my $self = shift;
    my $announcer = $self->make_announcer;

    my $runs = 0;

    $announcer->when('Announcement1', sub { $runs++ }, for => 'label1');
    $announcer->when('Announcement1', sub { $runs++ }, for => 'label2');

    is +$announcer->subscription_registry->all_subscriptions => 2, 'Added 2 subscriptions';
    $announcer->unsubscribe('label1');
    $announcer->announce('Announcement1');
    is $runs => 1, "Only label1s";
}

sub test_when_with_for_object : Test(1) {
    my $self = shift;
    my $announcer = $self->make_announcer;

    my $sub1 = Subscriber->new;
    my $sub2 = Subscriber->new;

    my $runs = 0;

    $announcer->when('Announcement1', sub { $runs++ }, for => $sub1);
    $announcer->when('Announcement1', sub { $runs++ }, for => $sub2);

    $announcer->unsubscribe($sub1);
    $announcer->announce('Announcement1');

    is $runs => 1, 'Only $sub2';
}

sub test_announcing_with_an_instance : Test(1) {
    my $self = shift;
    my $announcer = $self->make_announcer;

    my $message = '';

    $announcer->when(Announcement1 => sub {$message = $_[0]->message});
    $announcer->announce(Announcement1->new(message => 'message'));

    is $message => 'message', 'message';
}

sub test_announce_sets_dollar_underscore : Test(1) {
    my $self = shift;
    my $announcer = $self->make_announcer;

    my $message = '';

    $announcer->when(Announcement1 => sub {$message = $_->message});
    $announcer->announce(Announcement1->new(message => 'message'));

    is $message => 'message', 'got announcement from $_';
}


__PACKAGE__->runtests unless caller;
