# Things to set up on a new GNOME:

## Change to the Emacs keybinding theme
"Windows key" -> "Tweak Tool" -> "Keyboard and Mouse" -> "Key theme" ==> Emacs
## Swap Ctrl and Caps Lock
"Windows key" -> "Tweak Tool" -> "Typing" -> "Ctrl key position" ==> "Swap Ctrl and Caps Lock"
## Show date & seconds on the clock
"Windows key" -> "Tweak Tool" -> "Top Bar" ==> Show date & show seconds
## Focus follows mouse
"Windows key" -> "Tweak Tool" -> "Windows" -> "Focus Mode" ==> "Sloppy"
## Make the Terminal not have menu-bars
"Windows key" -> "Terminal" -> "Edit" -> "Preferences" -> "General" ==> "Show menubar by default..."
## Make the Terminal grey on black
"Windows key" -> "Terminal" -> "Right Click" -> "Profiles" -> "Profile Preferences" -> "Colors" -> "Built-in schemes" ==> "Grey on black"
## Disable Terminal Bell
"Windows key" -> "Terminal" -> "Right Click" -> "Profiles" -> "Profile Preferences" -> "General" -> ==> "Terminal bell" = "Off"
## Disable Alerts
"Windows key" -> "Sound" -> "Sound Effects" ==> "Alert volume" = "Off"
## Set the touchpad to edge scrolling
"Windows key" -> "dconf editor" -> "org.gnome.settings-daemon.peripherals.touchpad" -> "scroll method" ==> "edge-scrolling" && "natural scroll" => "Off"

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
