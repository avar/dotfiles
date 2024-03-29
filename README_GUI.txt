# On a new debian

I'll now get in /var/log/daemon.log:

    Nov 10 19:15:22 gmgdl bluetoothd[5181]:
    src/service.c:btd_service_connect() a2dp-sink profile connect
    failed for 28:52:E0:E7:BE:F7: Protocol not available

Apparently Debian/Wayland configured it instead of PulseAudio:
https://wiki.debian.org/PipeWire

Need to enable it now? Some combination of:

    systemctl --user enable pulseaudio.service
    systemctl --user disable pipewire.service
    systemctl --user stop pipewire.service
    systemctl --user start pulseaudio.service

See:

* https://wiki.archlinux.org/title/systemd/User#Automatic_start-up_of_systemd_user_instances
* https://wiki.debian.org/PulseAudio

# Things to set up on a new GNOME:

## Disable Alerts
"Windows key" ==> "Sound" ==> "Sound Effects" ==> "Alert volume" ==> "Off"

Apparently this doesn't work in recent versions. You need:

"dconf" -> search for "event-sounds" -> turn it off

## Natural scrolling
"Windows key" ==> "Mouse & Touchpad ==> "Mouse" ==> "Natural Scrolling"


### Tweaks (used to be gnome-tweak-tool)
## Change to the Emacs keybinding theme
"Windows key" ==> "Tweaks" ==> "Keyboard and Mouse" ==> "Emacs Input" ==> On
## Swap Ctrl and Caps Lock
"Windows key" ==> "Tweaks" ==> "Keyboard and Mouse" ==> "Additional Layout Options" ==> "Ctrl position" ==> "Swap Ctrl and Caps Lock"
## Show date & seconds on the clock
"Windows key" ==> "Tweaks" ==> "Top Bar" ==> "Clock" ==> ["Weekday" ==> "On" && "Date" ==> "On" && "Seconds" ==> "On"]
## Show battery %
"Windows key" ==> "Tweaks" ==> "Top Bar" ==> "Battery Percentage"
## Focus follows mouse
"Windows key" ==> "Tweaks" ==> "Windows" ==> "Window Focus" ==> "Focus on Hover"

## Make the Terminal not have menu-bars
"Windows key" ==> "Terminal" ==> "Edit" ==> "Preferences" ==> "General" ==> "Show menubar by default in new terminals" ==> "On"
## Make the Terminal grey on black
"Windows key" ==> "Terminal" ==> "Edit" ==> "Profiles" ==> "Colors" ==> "Built-in schemes" ==> "Grey on black"
## Disable Terminal Bell
"Windows key" ==> "Terminal" ==> "Edit" ==> "Profiles" ==> "Text" ==> "Terminal bell" ==> "Off"

# Make sure we're running XOrg
## This is needet so that the "yubikey:hook" part of my local screen
## works. Can't figure out a way to set a keyboard layout X on one
## keyboard and layout Y on another at the same time under Wayland
"Logout" -> "Setting icon" -> "GNOME + XOrg"

# Set up mbsync+mu+emacs
cd ~/g/elisp && make

# Other:
## Switch the default display for menubars etc.
xrandr --output HDMI3 --primary

## Console keymap

Sometimes the console keymap reverts back to QWERTY. Not quite sure
why, but happened on an apt upgrade once.

Running this in X seems to have fixed it:

    sudo update-initramfs -u

The internet suggested localectl and /etc/vconsole.conf, which was
changed by *something* from KEYMAP=is-latin1 to KEYMAP=dvorak,
probably the update-initramfs command itself. I think it just reads
your current settings.

The important thing to realize is that the bootup password request
doesn't read /etc/vconsole.conf directly because we haven't decrypted
/ at that point, rather it freezes whatever the setting is in
initramfs.

Update: recently this broke, setting it back to dvorak and running
update-initramfs -u didn't fix it. Running it would yield:

    Warning: error while trying to store keymap file - ignoring
    request to install /etc/boottime.kmap.gz

Per https://lists.debian.org/debian-kernel/2015/05/msg00288.html I
needed to do:

    dpkg-reconfigure keyboard-configuration

And now I'm okey again!
