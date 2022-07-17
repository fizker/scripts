.PHONY: bin build clean default
.SILENT:

default: bin

build:
	swift build --configuration release

clean:
	rm -rf bin

bin/resize-image: build
	mkdir -p bin
	cp `swift build --configuration release --show-bin-path`/resize-image bin/

bin/git-scripts: build
	mkdir -p bin
	cp `swift build --configuration release --show-bin-path`/git-scripts bin/

bin: bin/resize-image bin/git-scripts
