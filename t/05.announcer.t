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
__PACKAGE__->runtests unless caller;
