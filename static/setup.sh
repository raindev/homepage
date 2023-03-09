#!/usr/bin/env bash
# Downloads github.com/raindev/env and launches setup
set -euo pipefail

if ! command -v nix > /dev/null; then
	echo '>installing Nix'
	sh <(curl -sSL https://nixos.org/nix/install) --daemon
fi
curl -sSL https://raw.githubusercontent.com/raindev/nix-config/main/configure > /tmp/configure
chmod +x /tmp/configure
/tmp/configure
