BUNDLER := $(shell gem spec bundler 2> /dev/null)
XCMETRICS := $(shell test -e XCMetrics && test -e XCMetricsLauncher || echo false)

bundle_exec := bundle exec 

OBJ_COLOR= \033[0;36m
NO_COLOR=\033[m

XCODE_USER_TEMPLATES_DIR=~/Library/Developer/Xcode/Templates/File\ Templates

.DEFAULT_GOAL := setup
.PHONY = help \
		install_gems install_pods \
		install_gitchglog

setup: install_gems install_npm_package install_pods install_templates install_gitchglog install_xcmetrics

help: ## Quick help
	@echo ""
	@echo "Usage:"
	@echo "    make $(OBJ_COLOR)<target>$(NO_COLOR)"
	@echo ""
	@echo "Target:"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    $(OBJ_COLOR)%-30s$(NO_COLOR) %s\n", $$1, $$2}'
	@echo ""

install_pods: ## Install all Cocoapods dependencies
	$(bundle_exec) fastlane install_pods

############################################################
# XCMetrics
############################################################

# Use Spotify XCMetrics to gather build times: https://github.com/spotify/XCMetrics
install_xcmetrics:
ifneq ($(XCMETRICS),)
	git clone --branch v0.0.8 https://github.com/spotify/XCMetrics /tmp/XCMetrics
	swift build --package-path /tmp/XCMetrics --product XCMetrics -c release
	mv /tmp/XCMetrics/XCMetricsLauncher /tmp/XCMetrics/.build/release/XCMetrics ./Project
	rm -rf /tmp/XCMetrics
endif
