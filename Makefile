TAG ?= dev
CONTEXT ?= docker-for-desktop
NAMESPACE ?= default

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
