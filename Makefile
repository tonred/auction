
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

	@echo "build-{english/forward/blind}-forward - compile only this auction contract"
	@echo "tests-{english/forward/blind}-forward - test only this auction contract"
	@echo "build-blind-bid - compile blind bid contract"
	@echo "build-test-wallet: - build wallet for tests"

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

build: build-tip3 build-english-forward build-dutch-forward build-blind-forward build-blind-bid build-test-wallet
	@echo "Building all"

build-tip3:
	@echo "Building TIP3 Contracts"
	$(call compile_all,$(TIP3_CONTRACTS_PATH),RootTokenContract)
	$(call compile_all,$(TIP3_CONTRACTS_PATH),TONTokenWallet)
	$(call compile_all,$(TEST_CONTRACTS_PATH),TestTIP3RootDeployer)

build-english-forward:
	@echo "Building English Forward"
	$(call compile_all,$(CONTRACTS_PATH),EnglishForwardAuction)

build-dutch-forward:
	@echo "Building Dutch Forward"
	$(call compile_all,$(CONTRACTS_PATH),DutchForwardAuction)

build-blind-forward:
	@echo "Building Blind Forward"
	$(call compile_all,$(CONTRACTS_PATH),BlindForwardAuction)

build-blind-bid:
	@echo "Compiling Blind Bid"
	$(call compile_all,$(CONTRACTS_PATH),BlindBid)

build-test-wallet:
	@echo "Compiling Test Wallet"
	$(call compile_all,$(TEST_CONTRACTS_PATH),TestWallet)

tests: tests-english-forward tests-dutch-forward tests-blind-forward
	@echo "Testing all"

tests-english-forward:
	@echo "Testing English Forward"
	cd test/ts4 && python3 -m unittest english_forward.EnglishForwardAuctionTest && cd ../..

tests-dutch-forward:
	@echo "Testing Dutch Forward"
	cd test/ts4 && python3 -m unittest dutch_forward.DutchForwardAuctionTest && cd ../..

tests-blind-forward:
	@echo "Testing Blind Forward"
	cd test/ts4 && python3 -m unittest blind_forward.BlindForwardAuctionTest && cd ../..


define compile_all
	$(call compile_tondev,$(1),$(2))
	$(call tvc_to_base64,$(ARTIFACTS_PATH)/$(2))
endef

define compile_tondev
	tondev sol compile $(1)/$(2).sol -o $(ARTIFACTS_PATH)
endef

define tvc_to_base64
	base64 $(1).tvc > $(1).base64
endef

