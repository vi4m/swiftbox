DOCKER_TAG = swiftbox-dev:latest
WORKDIR = /opt/swiftbox

update:
	swift package update

xcode:
	swift package generate-xcodeproj

debug:
	swift build -v -c debug

release:
	swift build -v -c release

test:
	swift test

docker_test:
	docker build . -f docker/Dockerfile-dev -t $(DOCKER_TAG)
	docker run --rm -v `pwd`:$(WORKDIR) $(DOCKER_TAG) make test

format:
	swiftformat --disable redundantSelf ./Sources

lint:
	swiftformat --lint --verbose --disable redundantSelf ./Sources

