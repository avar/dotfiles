use strict;
use Socket;
use Irssi;
use Irssi::Irc;

my $bitlbeeChannel = "&bitlbee";
my %nicksToRename = ();

sub message_join
{
  # "message join", SERVER_REC, char *channel, char *nick, char *address
  my ($server, $channel, $nick, $address) = @_;
  my $username = substr($address, 0, index($address,'@'));
  my $host = substr($address, index($address,'@')+1);

  if ($channel =~ m/($bitlbeeChannel)/ and $nick =~ m/$username/)
  {
    $nicksToRename{$nick} = $channel;
    $server->command("whois $nick");
  }
}

sub whois_data
{
  my ($server, $data) = @_;
  my ($me, $nick, $user, $host) = split(" ", $data);

  if (exists($nicksToRename{$nick}))
  {
    my $channel = $nicksToRename{$nick};
    delete($nicksToRename{$nick});

    my $ircname = substr($data, index($data,':')+1);

    $ircname =~ s/[^A-Za-z0-9]//g;
    $ircname = substr( $ircname, 0, 25 );

    if ($ircname ne $nick)
    {
      $server->command("msg $channel rename $nick $ircname");
      $server->command("msg $channel save");
    }
  }
}

Irssi::signal_add_first 'message join' => 'message_join';
Irssi::signal_add_first 'event 311' => 'whois_data';
