#!/usr/bin/env sh
# Downloads raindev/nix-config/configure and launches setup

if ! command -v nix > /dev/null; then
	echo '>installing Nix'
	curl -sSL https://nixos.org/nix/install > /tmp/nix-install.sh
	sh /tmp/nix-install.sh --daemon
	source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
fi
curl -sSL https://raw.githubusercontent.com/raindev/nix-config/main/configure > /tmp/configure.sh
chmod +x /tmp/configure.sh
/tmp/configure.sh
