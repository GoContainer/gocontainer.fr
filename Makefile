.DEFAULT_GOAL := help

watch: hugo-watch	## Launch server with draft

create: hugo-create	## Create a new post

build: gulp-build 	## Gulp build

hugo-watch:
	hugo server -D -w

hugo-create:
	bash -c "sh bin/create_post.sh"

gulp-build:
	gulp build

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
