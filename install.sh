#!/bin/bash

set -xe

SOUND_DEFAULT="${SOUND_DEFAULT:-/usr/share/sounds/freedesktop/stereo/bell.oga}"
SOUND_FERDIUM="${SOUND_FERDIUM:-/usr/share/sounds/freedesktop/stereo/message-new-instant.oga}"


cd "$(dirname $(realpath $0))"

# Move the executable into place
mkdir -p ~/bin
cp gaudible.py ~/bin/gaudible

# CentOS 7 doesn't support systemctl --user
if [[ "$(cat /etc/redhat-release)" =~ ^CentOS\ Linux\ release\ 7 ]]; then
	cat <<-EOT > ~/.config/autostart/gaudible.desktop
		[Desktop Entry]
		Name=gaudible
		Type=Application
		Exec=$HOME/bin/gaudible -v --sound "ferdium:$SOUND_FERDIUM" --filter "ferdium"
		Hidden=false
		NoDisplay=false
		Terminal=false
		X-GNOME-Autostart-enabled=true
	EOT
	exit
fi

# Create systemd service
mkdir -p ~/.config/systemd/user
cat <<-EOT > ~/.config/systemd/user/gaudible.service
	[Service]
	ExecStart=$HOME/bin/gaudible -v --sound "ferdium:$SOUND_FERDIUM" --filter "ferdium"
	Restart=always
	NoNewPrivileges=true

	[Install]
	WantedBy=default.target
EOT

# Enable systemd service
systemctl --user daemon-reload
systemctl --user stop gaudible
systemctl --user enable --now gaudible

# Check if it's running
journalctl --user -u gaudible -e --since '-1min'
