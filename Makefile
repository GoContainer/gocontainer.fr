.DEFAULT_GOAL := help

watch: hugo-watch	## Launch server with draft

create: hugo-create	## Create a new post

gulp: gulp-build 	## Gulp build

build: hugo-build	## Build project

hugo-watch:
	hugo server -D -w

hugo-create:
	bash -c "sh bin/create_post.sh"

gulp-build:
	gulp build

hugo-build:
	./bin/hugo -b https://gocontainer.fr/

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
