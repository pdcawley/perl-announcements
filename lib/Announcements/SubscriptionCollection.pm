use MooseX::Declare;
use feature ':5.10';
require Set::Object;

class Announcements::SubscriptionCollection {
    has _subscriptions => (
        is      => 'ro',
        default => sub { Set::Object->new },
    );

    use overload '<<'     => sub { $_[0]->add_subscription($_[1]) },
                 '@{}'    => sub { $_[0]->as_array },
                 '0+'     => sub { $_[0]->_subscriptions->size },
                 fallback => 1;

    method add_subscription (Announcements::Subscription $sub) {
        $self->_subscriptions->insert($sub);
        $self;
    }

    method contains (Announcements::Subscription $sub) {
        $self->_subscriptions->member($sub);
    }

    method as_array {
        [$self->_subscriptions->members];
    }

    method announce (Announcements::Announcement $ann) {
        $_->value($ann) foreach @$self;
    }
}

1;
