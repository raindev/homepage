#!/bin/bash
# Downloads github.com/raindev/env and launches setup
set -euo pipefail

if ! command -v git > /dev/null ; then
	if command -v xbps-install > /dev/null ; then
		sudo xbps-install --sync --yes git
	else
		echo "Don't know how to install git"
	fi
fi

if [ ! -e "$HOME/code/env" ]; then
	git clone https://github.com/raindev/env.git "$HOME/code/env/"
	cd "$HOME/code/env"
	git remote set-url origin git@github.com:raindev/env.git
fi
"$HOME/code/env/configure"
