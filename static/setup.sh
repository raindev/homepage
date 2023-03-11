#!/usr/bin/env sh
# Downloads raindev/nix-config/configure and launches setup

if ! command -v nix > /dev/null; then
	echo '>installing Nix'
	curl -sSL https://nixos.org/nix/install > /tmp/nix-install.sh
	sh /tmp/nix-install.sh --daemon
fi
curl -sSL https://raw.githubusercontent.com/raindev/nix-config/main/configure.sh > /tmp/configure.sh
chmod +x /tmp/configure.sh
bash -l -c /tmp/configure.sh
