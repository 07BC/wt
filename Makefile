.PHONY: build release test install clean help

build:
	swift build

release:
	swift build -c release

test:
	swift test

install: release
	cp .build/release/wt /usr/local/bin/wt

clean:
	swift package clean

help:
	@echo "Available targets:"
	@echo "  build   - Build debug version"
	@echo "  release - Build release version"
	@echo "  test    - Run unit tests"
	@echo "  install - Install to /usr/local/bin"
	@echo "  clean   - Clean build artefacts"
