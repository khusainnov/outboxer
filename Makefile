APP?=outboxer
export GO111MODULE=on
VERSION=$(shell git describe --tags)
LDFLAGS="-s -X main.VERSION=$(VERSION)"

.PHONY: build
build:
	go build -ldflags $(LDFLAGS) -a -o output

.PHONY: dev-down
dev-down:
	docker-compose -f deployments/docker-compose.yaml down --remove-orphans

.PHONY: dev-clean
dev-down:
	docker-compose -f deployments/docker-compose.yaml down -v --rmi all

.PHONY: dev-build
dev-down:
	docker-compose -f deployments/docker-compose.yaml build $(APP)-app

.PHONY: ci-lint
ci-lint:
	golangci-lint run --fix --timeout=1m -c .golangci.yml

.PHONY: @ci-lint
@ci-lint:
	docker-compose -f deployments/docker-compose.yaml run --rm $(APP)-ci-lint

help: #? display this help
	$(info Available targets)
	@awk '/^@?[a-zA-Z\-\_0-9]+:/ { \
		nb = sub( /^#\? /, "", helpMsg ); \
		if(nb == 0) { \
			helpMsg = $$0; \
			nb = sub( /^[^:]*:.* #\? /, "", helpMsg ); \
		} \
		if (nb) \
			printf "\033[1;31m%-" width "s\033[0m %s\n", $$1, helpMsg; \
		} \
	{ helpMsg = $$0 }' \
	$(MAKEFILE_LIST) | column -ts:


