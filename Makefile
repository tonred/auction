include .env

ifndef VERBOSE
.SILENT:
endif

help:
	@echo "setup - setup .env file from sample"
	@echo "build - build {input_dir}/{input_file} file"
	@echo "clean - clear build artifacts except ABI's"
	@echo "clean-tmp - clear temp build artifacts except tvc and ABI's"

setup:
	@echo "setup"
	cp .env.dist .env

clean: clean-tmp
	rm -f $(ARTIFACTS_PATH)/*.tvc \
		  $(ARTIFACTS_PATH)/*.js \
		  $(ARTIFACTS_PATH)/*.base64

clean-tmp:
	rm -f $(ARTIFACTS_PATH)/*.sh \
		  $(ARTIFACTS_PATH)/*.result \
		  $(ARTIFACTS_PATH)/*.code

dev: build deploy tests
	@echo "dev"

build: build-english-forward build-test-wallet
	@echo "Compiling all contracts"
#	$(call compile_all,$(CONTRACTS_PATH),$(AUCTION_CONTRACT))
#	$(call compile_all,$(CONTRACTS_PATH),$(AUCTION_ROOT_CONTRACT))
#	$(call compile_all,$(CONTRACTS_PATH),$(BID_CONTRACT))
#	$(call compile_all,$(TEST_CONTRACTS_PATH),$(TEST_WALLET_CONTRACT))

build-english-forward:
	@echo "Compiling EnglishForwardAuction"
	$(call compile_all,./contracts,EnglishForwardAuction)

buildt:
	@echo "Compiling EnglishForwardAuctionTest"
	$(call compile_all,./contracts/test,EnglishForwardAuctionTest)

build-test-wallet:
	@echo "Compiling TestWallet"
	$(call compile_all,./contracts/test,TestWallet)

build-root:
	@echo "Compiling AuctionRoot"
	$(call compile_all,./contracts,AuctionRoot)

deploy:
	@echo "Deploying Auction"
	npm run migrate

tests:
	@echo "Testing Auction"
	npm run test

define compile_all
	$(call compile_sol,$(1),$(2))
	$(call compile_tvm,$(2))
	$(call compile_client_code,$(ARTIFACTS_PATH)/$(2).sol)
	$(call tvc_to_base64,$(ARTIFACTS_PATH)/$(2))
endef

define compile_sol
	$(SOLC_BIN) $(1)/$(2).sol --tvm-optimize
	mv $(2).code $(ARTIFACTS_PATH)
	mv $(2).abi.json $(ARTIFACTS_PATH)
endef

define compile_tvm
	$(TVM_LINKER_BIN) compile $(ARTIFACTS_PATH)/$(1).code \
							   --lib $(STDLIB_PATH) \
							   --abi-json $(ARTIFACTS_PATH)/$(1).abi.json \
							   -o $(ARTIFACTS_PATH)/$(1).tvc
endef

define compile_client_code
	node $(CLIENT_JS_COMPILER) $(1)
endef

define tvc_to_base64
	base64 $(1).tvc > $(1).base64
endef
