use strict;
use warnings;
use Irssi;

our %IRSSI = (
    authors     => 'Ævar Arnfjörð Bjarmason',
    contact     => 'avarab@gmail.com',
    name        => 'Msg strip slack CC',
    description => 'Strips the annoying mentions of your nickname via [cc: <you>]',
    license     => 'Public Domain',
    url         => 'http://irssi.org/',
);

# HOWTO:
#
#   /load msg_strip_slack_cc.pl
#
# This should just automatically work, it'll detect if you're using
# the slack IRC gateway and auto-detect the nick it should be
# stripping as well.

sub rewrite_privmsg {
    my ($server, $data, $nick, $nick_and_address) = @_;
    my ($target, $message) = split /:/, $data, 2;

    return unless $server->{address} =~ /irc\.slack\.com$/s;
    my $wanted_nick = $server->{wanted_nick};
    return unless $message =~ s/ \[cc: \Q$wanted_nick\E\]$//s;

    my $new_data = "$target:$message";
    Irssi::signal_emit('event privmsg', $server, $new_data, $nick, $nick_and_address);
    Irssi::signal_stop();
}

Irssi::signal_add('event privmsg', 'rewrite_privmsg');
