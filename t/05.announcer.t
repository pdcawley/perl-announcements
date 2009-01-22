#!/usr/bin/env perl

package AnnouncerTest;
use strict;
use warnings;

use Announcements;

use MooseX::Declare;
class Announcement1 extends Announcements::Announcement {
}

class Announcement2 extends Announcements::Announcement {
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
__PACKAGE__->runtests unless caller;
