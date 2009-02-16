use MooseX::Declare;

use Announcements::SubscriptionRegistry;
use Announcements::Subscription;
use Announcements::TypeDefs qw(AnnouncementClass);

class Announcements::Announcer {
    use feature ':5.10';

    has subscription_registry => (
        is      => 'ro',
        isa     => 'Announcements::SubscriptionRegistry',
        builder => 'make_subscription_registry',
        lazy    => 1,
        handles => {
            _register => 'register',
            forget_subscriptions => 'forget_subscriptions',
        },
    );

    has subscription_class => (
        is      => 'rw',
        builder => 'default_subscription_class',
    );

    method make_subscription_registry {
        Announcements::SubscriptionRegistry->new;
    }

    method default_subscription_class {
        'Announcements::Subscription';
    }

    method when ($ac, CodeRef $action, :$for?) {
        $for //= $action;
        if (ref($ac) eq 'ARRAY') {
            $self->when($_, $action, $for) foreach @$ac;
        }
        else {
            my $sub = $self->subscription_class->new(
                action             => $action,
                announcer          > $self,
                subscriber         => $for,
                announcement_class => $ac,
            );
            $self->_register($sub);
        }
    }

    method announce ($announcement) {
        $announcement = $announcement->as_announcement;
        $self->subscription_registry->announce($announcement);
        return $announcement;
    }

    method unsubscribe ($subscriber) {
        my $registry = $self->subscription_registry;
        $registry->remove_subscriptions($registry->subscriptions_of($subscriber));
    }
}
__END__

=head1 NAME

Announcements::Announcer - Dispatches announcements to subscribers


=head1 VERSION

This document describes Announcements::Announcer version 0.0.1


=head1 SYNOPSIS

    use feature ':5.10';
    use Announcements;

    my $announcer = Announcements::Announcer->new();

    $announcer->when(Announcements::Announcement => sub {
        my ($announcement, $announcer, $subscriber) = (@_);
        say "Got an announcement of class: ", ref($announcement);
    });

    # Elsewhere

    package CustomAnnouncement;
    use base 'Announcements::Announcement';

    $announcer->announce('CustomAnnouncement');
    # "Got an announcement of class: CustomAnnouncement"


=head1 DESCRIPTION

Announcements::Announcer is responsible for managing subscriptions to
announcements and sending those announcements on to subscribers as they
happen.

=head1 INTERFACE

=head2 Instance methods

=over 4

=item B<when($class|@$classes, CodeRef $action, $subscriber?)>

This function sets up subscriptions for the announcer, so that when an
announcement of class C<$class> is made, the anonymous method C<$action> is
called. C<$subscriber> is a key used to allow unsubscription later, it defaults
C<$action>. If C<$class> is an array reference, it will create a subscription
for each announcement class in the list.

=item B<unsubscribe($subscriber)>

This function removes any subscriptions added for the given C<$subscriber>
(the third argument to C<when>).

=item B<announce($announcement|$announcement_class)>

This function finds all the subscriptions matching the C<$announcement>'s
class and its superclasses and evaluates their actions. The action gets three
arguments: C<$announcement>, the announcer object and the C<$subscriber> key
passed to the C<when> that set up the subscription.

=back

=head2 Overrideable 'policy' methods

=over 4

=item B<make_subscription_registry>

This method should return an object that acts like a
L<Announcements::SubscriptionRegistry>. Defaults to making an instance of
Announcements::SubscriptionRegistry.

=item B<default_subscription_class>

Defaults to L<Announcements::Subscription>.

The class used by C<when> to make subscriptions. Should support the
Announcements::Subscription protocol/role.

=back

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language 
Announcer requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=head2 Limitations

This should really be available as a role for mixing in to other concrete
classes.

=head2 Bugs

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-announcer@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Piers Cawley  C<< <pdcawley@bofh.org.uk> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Piers Cawley C<< <pdcawley@bofh.org.uk> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
