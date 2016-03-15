use strict;
use warnings;
use Irssi;

our %IRSSI = (
    authors     => 'Ævar Arnfjörð Bjarmason',
    contact     => 'avarab@gmail.com',
    name        => 'MSG own nick to username',
    description => 'Changes messages from myself to appear to come from my username, not my nickname',
    license     => 'Public Domain',
    url         => 'http://irssi.org/',
);

# HOWTO:
#
#   /load msg_own_nick_to_username.pl
#
# This is for use on servers where your NICK is forced upon you,
# e.g. when connecting to some corporate maintained Bitlbee server
# that has LDAP-connected accounts.
#
# In that case your NICK may not be what you're used to. This
# intercepts PRIVMSG from you and rewrites them so that they appear to
# come from the "nick" configured in settings.core.user_name instead
# of whatever your nickname is on the server.
#
# This should just automatically work, it'll detect what your nick is,
# what you're username is, and automatically substitute
# s/nick/username/ if applicable.
#
# XXX TODO: This doesn't work, bugs:
#
#  - When you /query YOURNICK and type "hi" it ends up in another
#    window of YOURUSERNAME.
#
#  - When I type something in a channel it just plain doesn't work as
#    I expect. Only my NICK is visible. There's something deeper going
#    on here in irssi I expect with a NICK not being overridable in
#    the UI like this via PRIVMSG events.

sub msg_rename_myself_privmsg {
    my ($server, $data, $nick, $nick_and_address) = @_;
    my ($target, $message) = split /:/, $data, 2;

    # Unpack our configuration from $server.
    my $server_username = $server->{username};
    my $server_nick     = $server->{nick};

    # We have nothing to do here, our nick is already the same as our
    # username.
    return if $server_username eq $server_nick;

    # We only manipulate messages from ourselves
    return unless $server_nick eq $nick;

    # Emit our manipulated event with a fake nick & message.
    my $new_data = "$server_username :$message";
    Irssi::signal_emit('event privmsg', $server, $new_data, $server_username, $nick_and_address);
    Irssi::signal_stop();
}

Irssi::signal_add('event privmsg', 'msg_rename_myself_privmsg');
