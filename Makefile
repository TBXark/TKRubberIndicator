SHELL := /bin/bash

DERIVED_DATA ?= .build/DerivedData
SCHEME ?= TKRubberPageControl

# Leave empty to auto-select the first available iPhone simulator.
DESTINATION ?=

.PHONY: demo build test format lint ci

demo:
	./Scripts/demo.sh

build:
	@dest="$(DESTINATION)"; \
	if [ -z "$$dest" ]; then \
		name=$$(xcrun simctl list devices available | sed -n 's/^ *\(iPhone[^(]*\)(.*/\1/p' | head -1 | sed 's/ *$$//'); \
		dest="platform=iOS Simulator,name=$$name"; \
	fi; \
	echo "Building $(SCHEME) for $$dest"; \
	xcodebuild -scheme $(SCHEME) -destination "$$dest" -derivedDataPath $(DERIVED_DATA) build

test:
	@dest="$(DESTINATION)"; \
	if [ -z "$$dest" ]; then \
		name=$$(xcrun simctl list devices available | sed -n 's/^ *\(iPhone[^(]*\)(.*/\1/p' | head -1 | sed 's/ *$$//'); \
		dest="platform=iOS Simulator,name=$$name"; \
	fi; \
	echo "Testing $(SCHEME) on $$dest"; \
	xcodebuild -scheme $(SCHEME) -destination "$$dest" -derivedDataPath $(DERIVED_DATA) test

format:
	swift format --in-place --recursive Sources Tests Demo/Sources

lint:
	swift format lint --recursive --strict Sources Tests Demo/Sources

ci: build test lint
