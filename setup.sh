#!/bin/bash
# Downloads github.com/raindev/env and launches setup
set -euo pipefail

home=/home/raindev

if ! command -v git > /dev/null ; then
	if command -v xbps-install > /dev/null ; then
		xbps-install --sync --yes git
	else
		echo "Don't know how to install git"
	fi
fi

if [ ! -e "$home/code/env" ]; then
	su raindev -c "git clone https://github.com/raindev/env.git '$home/code/env/'"
	cd "$home/code/env"
	su raindev -c "git remote set-url git@github.com:raindev/env.git"
fi
"$home/code/env/configure"
