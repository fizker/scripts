.PHONY: bin build clean default
.SILENT:

default: bin

build:
	swift build -c release

clean:
	rm -rf bin

bin/resize-image: build
	mkdir -p bin
	cp `swift build --show-bin-path`/resize-image bin/

bin: bin/resize-image
