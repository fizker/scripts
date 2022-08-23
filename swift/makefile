.PHONY: bin build clean default
.SILENT:

default: bin

current_sha = $(shell git log -1 --pretty=%H)

build:
ifneq ($(current_sha), $(shell cat .latest-build 2> /dev/null))
	swift build --configuration release
	echo $(current_sha) > .latest-build
endif

clean:
	rm -rf bin .latest-build

bin/resize-image: build
	mkdir -p bin
	cp `swift build --configuration release --show-bin-path`/resize-image bin/

bin/git-scripts: build
	mkdir -p bin
	cp `swift build --configuration release --show-bin-path`/git-scripts bin/

bin: bin/resize-image bin/git-scripts
