#!/usr/bin/env perl
use v5.14.2;
use strict;
use warnings;
use autodie qw(open close);
use JSON::XS;
use Data::Dumper;

# time (find ~/Maildir ~/Maildir.2016-07-11 -type f | perl ~/Maildir/scripts/extract-headers.pl > Maildir.headers)
# perl ~/Maildir/scripts/compare-maildirs.pl Maildir.headers|less -S

my $JSON_XS = JSON::XS->new->pretty(1)->canonical(1);

open my $fh, "<", shift;
my $content = do { local $/; <$fh> };
close $fh;
my $data = $JSON_XS->decode($content);

for my $msgid (keys %$data) {
    my $cmp = $data->{$msgid};

    # We have the message in both mailboxes here
    next if @$cmp == 2;
    unless (@$cmp == 1) {
        #warn "Found odd collection of " . @$cmp . " messages with msgid $msgid";
        next;
    }

    my $one = $cmp->[0];
    my $maildir = $one->{maildir};

    # If it's in the Exchange version it got copied over OK
    next if $maildir eq 'Maildir';

    say "$one->{headers}->{date}\t$msgid\t$one->{headers}->{subject}";
}
