#!/usr/bin/env perl

package Subscription::Test;
use strict;
use warnings;

use base qw(Test::Class);
use Test::More;

use Announcements;

sub make_announcement : Test(setup) {
    shift->{subscription} = Announcements::Subscription->new()
}

sub test_action_value : Test(3) {
    my($self) = (@_);

    my $sub = $self->subscription;
    $sub->action(sub { 1; });
    ok $sub->value(Announcements::Announcement->new());

    my $ann = Announcements::Announcement->new;
    $sub->action(sub { $_[0] });
    is $sub->value($ann) => $ann;

    my $announcer = Announcements::Announcer->new;
    $sub->announcer($announcer);
    $sub->action(sub { $_[1] });
    is $sub->value($ann) => $announcer;
}

sub test_instantiation : Test(1) {
    my $self = shift;

    isa_ok $self->subscription => 'Announcements::Subscription';
}


sub test_announcement_class : Test(1) {
    my $sub = $_[0]->subscription;

    $sub->announcement_class('Announcements::Announcement');
    is $sub->announcement_class => 'Announcements::Announcement';
}

sub subscription {
    shift->{subscription};
}

unless(caller) {
    Test::Class->runtests;
}
