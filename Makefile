all:
	cd src/ && cabal run -- build && cp -r _site/ ..

run:
	cd src/ && cabal run -- watch
