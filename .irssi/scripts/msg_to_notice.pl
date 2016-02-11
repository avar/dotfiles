use strict;
use warnings;

use Irssi;

use vars qw($VERSION %IRSSI);
$VERSION = "1";
%IRSSI = (
    authors     => 'Fernando Vezzosi',
    contact     => 'irssi@repnz.net',
    name        => 'Msg to Notice',
    description => 'Transform messages from some nicknames into notices',
    license     => 'Public Domain',
    url         => 'http://irssi.org/',
    changed     => '2013-04-24T17:40+0200',
);

# HOWTO:
#
#   /load msg_to_notice.pl
#   /set noticeable_nicks ~\[bot\]$,~mon-[0-9]+$,~^mon-.*-[0-9]+$,root,deploy,log,jenkins,nagmetoo
#
# The nicks that match will be turned into notices, useful for marking
# bots as such. Note that if the nicks start with ~ the rest is taken
# to be a regex. Due to limitations of our dummy parser you can't use
# {x,y} character classes or other regex constructs that require a
# comma, but usually that's something you can work around.

use constant {
    I_SERVER => 0,
    I_DATA   => 1,
    I_NICK   => 2,
    I_MASK   => 3,
    I_TARGET => 4,
};

sub handle_privmsg {
    # my ($target, $message) = split /:/, $_[I_DATA];

    # Irssi::print("server<$_[I_SERVER]> data<$_[I_DATA]>[$target:$message] nick<$_[I_NICK]> mask<$_[I_MASK]> target<@{[ $_[I_TARGET] // '(undef)' ]}>");
    my $is_noticeable = 0;
    for my $noticeable_nick ( split /[\s,]+/, Irssi::settings_get_str('noticeable_nicks') ) {
        $noticeable_nick =~ s/\A \s+//x;
        $noticeable_nick =~ s/\s+ \z//x;
        my $is_regexp; $is_regexp = 1 if $noticeable_nick =~ s/^~//;

        # Irssi::print("Checking <$_[I_NICK]> to <$noticeable_nick> via <" . ($is_regexp ? "rx" : "eq") . ">");
        if ( $is_regexp and $_[I_NICK] =~ $noticeable_nick ) {
            # Irssi::print("Matched <$_[I_NICK]> to <$noticeable_nick> via <rx>");
            $is_noticeable = 1;
            last;
        } elsif ( not $is_regexp and lc $noticeable_nick eq lc $_[I_NICK] ){
            # Irssi::print("Matched <$_[I_NICK]> to <$noticeable_nick> via <eq>");
            $is_noticeable = 1;
            last;
        }
    }
    return unless $is_noticeable;

    Irssi::signal_emit('event notice', $_[I_SERVER], $_[I_DATA], $_[I_NICK], $_[I_MASK]);
    Irssi::signal_stop();
}

Irssi::settings_add_str('msg_to_notice', 'noticeable_nicks', '~\[bot\]$,root,deploy');
Irssi::signal_add('event privmsg', 'handle_privmsg');

# vim: filetype=perl tabstop=4 shiftwidth=4 expandtab cindent:
