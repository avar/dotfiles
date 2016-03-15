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

sub msg_rename_myself_in_printed_text {
    my ($tdest, $data, $stripped) = @_;

    # The $tdest object has various other things, like ->{target},
    # ->{window} (object) etc.
    my $server = $tdest->{server};

    # Some events just hawe ->{window} and no ->{server}, we can
    # ignore those
    return unless $server;

    # Unpack our configuration from $server.
    my $server_username = $server->{username};
    my $server_nick     = $server->{nick};

    # We have nothing to do here, our nick is already the same as our
    # username.
    return if $server_username eq $server_nick;

    # FIXME: Doesn't do anything to the UI either
    s/$server_nick/$server_username/g for $data, $stripped;

    #use Data::Dumper;
    #open my $fh, ">>", "/tmp/irssi.log";
    #print $fh "Raw print event = " . Data::Dumper->new([[$data, $stripped]])->Useqq(1)->Indent(1)->Purity(1)->Deparse(1)->Sortkeys(\&_sortkeys)->Dump();
    #close $fh;

    Irssi::signal_continue($tdest, $data, $stripped);

    ## Infinite loop!
    #Irssi::signal_emit('print text', $tdest, $data, $stripped);
    #Irssi::signal_stop();

    return;
}

Irssi::signal_add_last('print text', 'msg_rename_myself_in_printed_text');
