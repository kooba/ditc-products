TAG ?= dev
# docker

run-wheel-builder:
	docker run --rm \
		-v "$$(pwd)":/application -v "$$(pwd)"/wheelhouse:/wheelhouse \
		jakubborys/ditc-wheel-builder:latest;

build-image:
	docker build -t jakubborys/ditc-products:$(TAG) .;

push-image:
	docker push jakubborys/ditc-products:$(TAG)

build: run-wheel-builder build-image push-image
