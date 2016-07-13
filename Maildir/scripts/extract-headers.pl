#!/usr/bin/env perl
use v5.14.2;
use strict;
use warnings;
use autodie qw(open close);
use JSON::XS;

my $JSON_XS = JSON::XS->new->pretty(1)->canonical(1);

my %msgid;
my $i;
while (my $file = <>) {
    chomp $file;
    my ($maildir) = $file =~ m[^/home/avar/([^/]+)/] or die;
    my $headers = get_basic_headers($file);

    unless ($headers->{msgid}) {
        ## This is because the Message-ID is indented on the next
        ## line, I would solve this with a real header parser, but I
        ## don't care, just skip these.
        #warn "Couldn't get a Message-ID from <$file>: <" . Dumper($headers) . ">" 
        next;
    }

    push @{$msgid{$headers->{msgid}}} => {
        maildir => $maildir,
        headers => $headers,
    };

    ## pv -s 1571490
    #print ".";
}
my $json = $JSON_XS->encode(\%msgid);
print $json;

sub get_basic_headers {
    my ($file) = @_;

    my %ret;
    open my $fh, "<", $file;
    LINE: while (my $line = <$fh>) {
        chomp $line;

        last LINE if $line =~ /^$/;

        if ($line =~ /^From:\s+(.*)\s*/i) {
            $ret{from} = $1;
            next LINE;
        }

        if ($line =~ /^To:\s+(.*)\s*/i) {
            $ret{to} = $1;
            next LINE;
        }

        if ($line =~ /^Subject:\s+(.*)\s*/i) {
            $ret{subject} = $1;
            next LINE;
        }

        if ($line =~ /^Date:\s+(.*)\s*/i) {
            $ret{date} = $1;
            next LINE;
        }

        if ($line =~ /^Message-ID:\s+(.*)\s*/i) {
            $ret{msgid} = $1;
            next LINE;
        }

        if ($line =~ /^List-Id:\s+(.*)\s*/i) {
            $ret{listid} = $1;
            next LINE;
        }
    }

    return \%ret;
}
