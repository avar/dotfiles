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

        if ( lc $noticeable_nick eq lc $_[I_NICK] ){
            $is_noticeable = 1;
            last;
        }
    }
    return unless $is_noticeable;

    Irssi::signal_emit('event notice', $_[I_SERVER], $_[I_DATA], $_[I_NICK], $_[I_MASK]);
    Irssi::signal_stop();
}

Irssi::settings_add_str('msg_to_notice', 'noticeable_nicks', 'root,deploy');
Irssi::signal_add('event privmsg', 'handle_privmsg');

# vim: filetype=perl tabstop=4 shiftwidth=4 expandtab cindent:
