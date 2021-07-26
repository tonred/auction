
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

dev: build tests
	@echo "dev"

debot: build-debot deploy-debot
	@echo "debot"

# BUILD AUTOGENERATED
build: build-english-forward build-english-reverse build-dutch-forward build-dutch-reverse build-blind-forward build-blind-reverse build-blind-bid build-auction-root build-test-auction-root build-test-wallet build-test-usage build-test-deployer
	@echo "Building all"

build-english-forward:
	@echo "Building English Forward"
	$(call compile_all,$(CONTRACTS_PATH),EnglishForwardAuction)

build-english-reverse:
	@echo "Building English Reverse"
	$(call compile_all,$(CONTRACTS_PATH),EnglishReverseAuction)

build-dutch-forward:
	@echo "Building Dutch Forward"
	$(call compile_all,$(CONTRACTS_PATH),DutchForwardAuction)

build-dutch-reverse:
	@echo "Building Dutch Reverse"
	$(call compile_all,$(CONTRACTS_PATH),DutchReverseAuction)

build-blind-forward:
	@echo "Building Blind Forward"
	$(call compile_all,$(CONTRACTS_PATH),BlindForwardAuction)

build-blind-reverse:
	@echo "Building Blind Reverse"
	$(call compile_all,$(CONTRACTS_PATH),BlindReverseAuction)

build-blind-bid:
	@echo "Compiling BlindBid"
	$(call compile_all,$(CONTRACTS_PATH),BlindBid)

build-auction-root:
	@echo "Compiling AuctionRoot"
	$(call compile_all,$(CONTRACTS_PATH),AuctionRoot)

build-test-auction-root:
	@echo "Compiling TestAuctionRoot"
	$(call compile_all,$(TEST_CONTRACTS_PATH),TestAuctionRoot)

build-test-wallet:
	@echo "Compiling TestWallet"
	$(call compile_all,$(TEST_CONTRACTS_PATH),TestWallet)

build-test-usage:
	@echo "Compiling TestUsage"
	$(call compile_all,$(TEST_CONTRACTS_PATH),TestUsage)

build-test-deployer:
	@echo "Compiling TestDeployer"
	$(call compile_all,$(TEST_CONTRACTS_PATH),TestDeployer)

build-debot:
	@echo "Compiling Debot"
	$(call compile_all,$(CONTRACTS_PATH)/debot,AuctionDebot)

# TESTS AUTOGENERATED
tests: tests-english-forward tests-english-reverse tests-dutch-forward tests-dutch-reverse tests-blind-forward tests-blind-reverse tests-auction-root tests-workflow
	@echo "Testing all"

tests-english-forward:
	@echo "Testing English Forward"
	cd test/ts4 && python3 -m unittest english_forward.EnglishForwardAuctionTest && cd ../..

tests-english-reverse:
	@echo "Testing English Reverse"
	cd test/ts4 && python3 -m unittest english_reverse.EnglishReverseAuctionTest && cd ../..

tests-dutch-forward:
	@echo "Testing Dutch Forward"
	cd test/ts4 && python3 -m unittest dutch_forward.DutchForwardAuctionTest && cd ../..

tests-dutch-reverse:
	@echo "Testing Dutch Reverse"
	cd test/ts4 && python3 -m unittest dutch_reverse.DutchReverseAuctionTest && cd ../..

tests-blind-forward:
	@echo "Testing Blind Forward"
	cd test/ts4 && python3 -m unittest blind_forward.BlindForwardAuctionTest && cd ../..

tests-blind-reverse:
	@echo "Testing Blind Reverse"
	cd test/ts4 && python3 -m unittest blind_reverse.BlindReverseAuctionTest && cd ../..

tests-auction-root:
	@echo "Testing Auction Root"
	cd test/ts4 && python3 -m unittest root.RootAuctionTest && cd ../..

tests-workflow:
	@echo "Testing Workflow"
	cd test/ts4 && python3 -m unittest workflow.WorkflowTest && cd ../..

deploy-root:
	@echo "Deploying Root contract"
	node migration/2-deploy-AuctionRoot.js
	
deploy-test-deployer:
	@echo "Deploying TestDeployer contract"
	node migration/3-deploy-TestAuctionDeployer.js

deploy-debot:
	@echo "Deploying Debot contract"
	node migration/4-deploy-Debot.js

deploy-test-wallet:
	@echo "Deploying TestWallet contract"
	node migration/3-deploy-TestWallet.js

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

