all:
	cd src/ && zola build && cp -r public/* ..

run:
	cd src/ && zola serve
