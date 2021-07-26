
-include .env

ifndef VERBOSE
.SILENT:
endif

help:
	@echo "setup - setup .env file from sample"
	@echo "build - compile all contracts"
	@echo "tests - test all contracts"
	@echo "deploy - deploy all contracts"
	@echo "clean - clear build artifacts except ABI's"
	@echo "clean-tmp - clear temp build artifacts except tvc and ABI's"
	@echo "dev - build and test all contracts"

	@echo "build-{english/forward/blind}-{forward/reverse} - compile only this auction contract"
	@echo "tests-{english/forward/blind}-{forward/reverse} - test only this auction contract"
	@echo "build-blind-bid - compile blind bid contract"
	@echo "build-test-auction-root: - build auction root contract for tests"
	@echo "{build/tests}-auction-root - build/test auction root contract"
	@echo "build-test-wallet: - build wallet for tests"
	@echo "build-test-usage: - build contract for workflow tests"
	@echo "tests-workflow: - test full workflow"

	@echo "deploy - deploy auction root to blockchain"

setup:
	@echo "Setup"
	cp .env.dist .env
	npm install

create:
	@echo "Creating makefile"
	python3 makefile_generator.py

clean: clean-tmp
	rm -f $(ARTIFACTS_PATH)/*.tvc \
		  $(ARTIFACTS_PATH)/*.js \
		  $(ARTIFACTS_PATH)/*.base64

clean-tmp:
	rm -f $(ARTIFACTS_PATH)/*.sh \
		  $(ARTIFACTS_PATH)/*.result \
		  $(ARTIFACTS_PATH)/*.code

build-english-forward:
	@echo "Building English Forward"
	$(call compile_all,$(CONTRACTS_PATH),EnglishForwardAuction)

tests-english-forward:
	@echo "Testing English Forward"
	cd test/ts4 && python3 -m unittest english_forward.EnglishForwardAuctionTest && cd ../..

define compile_all
	$(call compile_tondev,$(1),$(2))
	$(call tvc_to_base64,$(ARTIFACTS_PATH)/$(2))
endef

define compile_tondev
	tondev sol compile $(1)/$(2).sol
	mv $(2).abi.json $(ARTIFACTS_PATH)
    mv $(2).tvc $(ARTIFACTS_PATH)
endef

define tvc_to_base64
	base64 $(1).tvc > $(1).base64
endef

