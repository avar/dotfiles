# Show seconds on the clock
gsettings set org.gnome.shell.clock show-seconds true
# Disable menubar in gnome-terminal
gconftool --type boolean --set /apps/gnome-terminal/profiles/Default/default_show_menubar false
# Switch the default display for menubars etc.
xrandr --output HDMI3 --primary
# Change to the Emacs keybinding theme
"Advanced Settings" -> "Theme" -> "Keybinding theme" ==> Emacs, can't
find a CLI way to do it
