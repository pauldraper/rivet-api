.DELETE_ON_ERROR:

.PHONY: format
format: target/format.target

target/format.target:
	mkdir -p $(@D)
	node_modules/.bin/prettier --write .
	# > $@

target/node_modules.target:
	mkdir -p $(@D)
	yarn install
	> $@

YAML_SRC := $(shell find api -name '*.yml')

api.yml: api/api.yml target/node_modules.target $(YAML_SRC)
	node_modules/.bin/swagger-cli bundle $< --type yaml > $@

api.html: api.yml redoc-options.txt
	node_modules/.bin/redoc-cli bundle --output $@ $< $$(cat redoc-options.txt)

deploy: api.yml
	aws --profile rivet-prod s3 cp --cache-control max-age=60 index.html s3://rivethealth-prod-io/index.html
	aws --profile rivet-prod s3 cp --cache-control max-age=60 api.yml s3://rivethealth-prod-io/api.yml
