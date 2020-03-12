all:
	cd src/ && zola build && cp -r public/* .. && rm -r public/

run:
	cd src/ && zola serve
