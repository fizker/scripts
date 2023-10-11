.PHONY: bin build clean default
.SILENT:

default: bin

current_sha = $(shell git log -1 --pretty=%H)
latest_build = $(shell cat .latest-build 2> /dev/null)

build:
ifneq ($(current_sha), $(latest_build))
	swift build --configuration release
	echo $(current_sha) > .latest-build
endif

clean:
	rm -rf bin .latest-build

bin: build
ifneq ($(current_sha), $(latest_build))
	@mkdir -p bin
	@path=`swift build --configuration release --show-bin-path`; \
	cp "$$path"/resize-image bin/ ;\
	cp "$$path"/git-scripts bin/ ;\
	cp "$$path"/reorder-paths bin/ ;\

endif
