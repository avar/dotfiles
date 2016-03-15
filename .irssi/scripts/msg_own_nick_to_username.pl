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
# intercepts "print text" events from irssi and rewrites them so that
# they appear to come from the "nick" configured in
# settings.core.user_name instead of whatever your nickname is on the
# server.
#
# The result is that you'll appear to yourself to have your "correct"
# nickname. The illusion goes pretty far, even down to your IRC logs,
# but of course everyone else will see you as your real nickname, or
# maybe your username (I use this for a IRC->Slack/Bitlee gateway).
#
# This should just automatically work, it'll detect what your nick is,
# what you're username is, and automatically substitute
# s/nick/username/ if applicable.

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

    # We're matching against $stripped but replacing both because the
    # $data thing is escaped and much harder to match against.
    #
    # We're just replacing nick mentions, so e.g. if you say "Hi I'm
    # bob here but my username is bobby" it won't turn into "Hi I'm
    # bobby here but my username is bobby".
    #
    # The illusion here isn't complete, e.g. if you do /NAMES your
    # nick will show up and not your username, but I consider that a
    # feature.
    if ($stripped =~ /^<.?\Q$server_nick\E> /s) {
        ## DEBUG:
        #open my $fh, ">>", "/tmp/irssi.log";
        #print $fh "Before: " . my_dump([$data, $stripped]);

        s/\Q$server_nick\E/$server_username/ for $data, $stripped;

        ## DEBUG:
        #print $fh "After: " . my_dump([$data, $stripped]);
        #close $fh;

        Irssi::signal_continue($tdest, $data, $stripped);
    }
}

Irssi::signal_add_first('print text', 'msg_rename_myself_in_printed_text');

sub my_dump {
    require Data::Dumper;

    return Data::Dumper->new([@_])->Useqq(1)->Indent(1)->Purity(1)->Deparse(1)->Sortkeys(\&_sortkeys)->Dump();
}
