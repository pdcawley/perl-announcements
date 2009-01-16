use MooseX::Declare;
use feature ':5.10';
require Set::Object;

class Announcements::SubscriptionCollection {
    has _subscriptions => (
        is => 'ro',
        default => sub { Set::Object->new },
    );

    use overload '<<' => \&_overload_extend, fallback => 1;

    sub _overload_extend { $_[0]->add_subscription($_[1]); }

    method add_subscription (Announcements::Subscription $sub) {
        $self->_subscriptions->insert($sub);
        $self;
    }

    method contains (Announcements::Subscription $sub) {
        $self->_subscriptions->member($sub);
    }
}

1;
