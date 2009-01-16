#!/usr/bin/env perl

use Test::More tests => 5;

BEGIN {
use_ok( 'Announcements' );
use_ok( 'Announcements::Announcement' );
use_ok( 'Announcements::Subscription' );
use_ok( 'Announcements::SubscriptionRegistry' );
use_ok( 'Announcements::Announcer' );
}

diag( "Testing Announcements $Announcements::VERSION" );
