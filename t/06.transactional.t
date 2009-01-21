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
    has is_vetoed => (is => 'rw', 'isa' => 'String', default => '');

    method veto ($reason = "vetoed") {
        $self->is_vetoed || $self->is_vetoed( $reason ); # First reason wins
    }
}

class ChangingValue extends ValueChangeAnnouncement {
}

class ChangedValue extends ValueChangeAnnouncement {
}

class ValueHolder {
    use feature ':5.10';
    our $INITIALISING = 0;

    my $announcer = Announcements::Announcer->new;

    has value => (
        is => 'rw',
        isa => 'Any',
    #    initializer => 'init_value',
    );

    method announcer () {
        $announcer;
    }

    method init_value ($value, $set) {
        say 4;
        $self->$set($value);
    }

    {
        my $value;
    around value ($value?) {
#        say $orig;
#        say $new_value;
        say 'around_value 1';
        return $self->$orig($value) unless $INITIALISING || defined($value);
        say 'around_value 2';
        my $old_value = $self->$orig();
        my $about_to_change
        = AboutToChangeValue->from_to_instance( $old_value, $value, $self);

        $announcer->announce($about_to_change);
        return if $about_to_change->is_vetoed;
        my $changing =
        ChangingValue->from_to_instance( $old_value, $value, $self);
        $announcer->announce($changing);
        $self->$orig($changing->$value);
        $announcer->announce(ChangedValue->from_to_instance( $old_value, $self->$orig(), $self ));
    }
}
}

package TransactionalTest;
use feature ':5.10';
use Test::More tests => 1;

ValueHolder->announcer->when(
    AboutToChangeValue => sub {
        my $ann = shift;
        $ann->veto;
    });

say 1;
my $vh = ValueHolder->new(value => 22);
say 2;
say $vh->value;
is $vh->value() => 22;
say 3;
