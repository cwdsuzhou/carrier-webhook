# Copyright 2021 The OCGI Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


REGISTRY_NAME=docker.io/ocgi
GIT_COMMIT=$(shell git rev-parse "HEAD^{commit}")
VERSION=$(shell git describe --tags --abbrev=14 "${GIT_COMMIT}^{commit}" --always)

CMDS=build-webhook
all: build

build: build-webhook

test:
	go test -v ./pkg/...

build-webhook:
	mkdir -p bin
	GOOS=linux CGO_ENABLED=0 go build -ldflags "-X 'github.com/ocgi/carrier-webhook/cmd/app.Version=$(VERSION)'" -o ./bin/webhook ./cmd

container: build-webhook
	docker build -t $(REGISTRY_NAME)/carrier-webhook:$(VERSION) -f $(shell if [ -e ./cmd/$*/Dockerfile ]; then echo ./cmd/$*/Dockerfile; else echo Dockerfile; fi) --label revision=$(REV) .

push: container
	docker push $(REGISTRY_NAME)/carrier-webhook:$(VERSION)
