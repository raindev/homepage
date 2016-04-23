all:
	cd src/ && cabal run -- build && cp -r _site/ ..

run:
	cd src/ && cabal run -- watch

clean:
	cd src/ && cabal run -- clean

hooks:
	cp -n src/hooks/* .git/hooks/
