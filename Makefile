all:
	cd hakyll/ && cabal run -- build && cp -r _site/ ..

run:
	cd hakyll/ && cabal run -- watch
