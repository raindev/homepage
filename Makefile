all:
	cd src/ && stack exec site build && cp -r _site/ ..

run:
	cd src/ && stack exec site watch

clean:
	cd src/ && stack exec site clean

hooks:
	cp -n src/hooks/* .git/hooks/
