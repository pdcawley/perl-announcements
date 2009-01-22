#!/usr/bin/env perl
#-*- perl -*-

use MooseX::Declare;
use Announcements;

class ValueChangeAnnouncement extends Announcements::Announcement {
    has old_value => (is => 'ro', 'isa' => 'Any');
    has new_value => (is => 'rw', 'isa' => 'Any');
    has instance  => (is => 'ro', 'isa' => 'ValueHolder', weak_ref => 1);

    method from_to_instance ($from, $to, $instance) {
        $self->new(old_value => $from,
                   new_value => $to,
                   instance => $instance,);
    }
}

class AboutToChangeValue extends ValueChangeAnnouncement {
    has is_vetoed => (is => 'rw', 'isa' => 'Str', default => '');

    method veto ($reason = "vetoed") {
        $self->is_vetoed || $self->is_vetoed( $reason ); # First reason wins
    }
}

class ChangingValue extends ValueChangeAnnouncement {
}

class ChangedValue extends ValueChangeAnnouncement {
}

class TransactionalAnnouncement extends Announcements::Announcement {
}

class Commited extends TransactionalAnnouncement {
}

class RollingBack extends TransactionalAnnouncement {
}

class ValueHolder extends Announcements::Announcer {
    use feature ':5.10';

    my $announcer = Announcements::Announcer->new;

    has value => (
        is => 'rw',
        isa => 'Any',
    );

    method announcer () {
        $announcer;
    }

    around value (:$value?) {
        my $old_value = $self->$orig();
        return $old_value unless defined($value);
        my $about_to_change
            = AboutToChangeValue->from_to_instance( $old_value, $value, $self);

        $self->announce($about_to_change);
        return if $about_to_change->is_vetoed;
        my $changing =
        ChangingValue->from_to_instance( $old_value, $value, $self);
        $self->announce($changing);
        $self->$orig($changing->new_value);
        $self->announce(ChangedValue->from_to_instance( $old_value, $self->$orig(), $self ));
    }

    after announce($announcement) {
        $announcer->announce($announcement);
    }
}

package TransactionalTest;
use feature ':5.10';
use Test::More tests => 7;
use Test::Exception;

my $announcer = ValueHolder->announcer;
$announcer->when(
    AboutToChangeValue => sub {
        my $ann = shift;
        $ann->veto;
    });

my $vh = ValueHolder->new(value => 22);
is $vh->value() => 22;
$vh->value(value => 33);
is $vh->value => 22;

$announcer->forget_subscriptions;

$announcer->when(ChangingValue => sub {
                     my $ann = shift;
                     $ann->new_value(uc($ann->new_value));
                 });

$vh->value(value =>"thingy");
is $vh->value => "THINGY";

my $vh2 = ValueHolder->new(value => 'immutable');
$vh2->when(AboutToChangeValue => sub {$_[0]->veto});

$vh2->value(value => 'mutable');
is $vh2->value => 'immutable';
$vh->value(value => 'mutable');
is $vh->value => 'MUTABLE';

sub transaction (&) {
    ValueHolder->announcer->when(
        ChangedValue => sub {
            my($ann) = shift;
            $ann->instance->rollback_func(
                sub { $_->value(value => $ann->old_value) }
            )
        },
        for => 'transaction'
    );

    my $value = eval { $_[0]->() };
    my $err = $@;
    ValueHolder->announcer->unsubscribe('transaction');
    if ($err) {
        ValueHolder->announcer->announce('RollingBack');
        die $err;
    }
    else {
        ValueHolder->announcer->announce('Commited');
    }
    $value;
}

is transaction { 1 } => 1, 'transaction returns block value';
throws_ok { transaction { die 'deliberately' } } qr/deliberately/, 'transaction should pass any exceptions on';
