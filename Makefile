CONTEXT ?= docker-for-desktop
NAMESPACE ?= default
TAG ?= $(shell git rev-parse HEAD)
REF ?= $(shell git branch | grep \* | cut -d ' ' -f2)
ENV_NAME ?= jakub

# Set GitHub Auth Token and Webhook Shared Secret here
GITHUB_TOKEN ?= ""

# Docker

run-wheel-builder:
	docker run --rm \
		-v "$$(pwd)":/application -v "$$(pwd)"/wheelhouse:/wheelhouse \
		jakubborys/ditc-wheel-builder:latest;

build-image:
	docker build -t jakubborys/ditc-products:$(TAG) .;

push-image:
	docker push jakubborys/ditc-products:$(TAG)

build: run-wheel-builder build-image push-image

retag:
	curl -XDELETE -H "Authorization: token $(GITHUB_TOKEN)" \
	"https://api.github.com/repos/kooba/ditc-products/git/refs/tags/dev"
	curl -XPOST -H "Authorization: token $(GITHUB_TOKEN)" \
	"https://api.github.com/repos/kooba/ditc-products/git/refs" \
	-d '{ "sha": "$(TAG)", "ref": "refs/tags/dev" }'

release:
	git add .
	git commit -m "Products Release $$(date)"
	git push origin $(REF)
	$(MAKE) build
	$(MAKE) retag

# Kubernetes

test-chart:
	helm upgrade products-$(NAMESPACE) charts/products --install \
	--namespace=$(NAMESPACE) --kube-context $(CONTEXT) \
	--dry-run --debug --set image.tag=$(TAG)

install-chart:
	helm upgrade products-$(NAMESPACE) charts/products --install \
	--namespace=$(NAMESPACE) --kube-context=$(CONTEXT) \
	--set image.tag=$(TAG)

lint-chart:
	helm lint charts/products --strict

# Bridage

install-brigade-deps:
	yarn install

lint-brigade:
	./node_modules/.bin/eslint brigade.js

run-brigade:
	echo '{"name": "$(ENV_NAME)"}' > payload.json
	brig run -c $(TAG) -r $(REF) -f brigade.js -p payload.json \
	kooba/ditc-products --kube-context $(CONTEXT) --namespace brigade
