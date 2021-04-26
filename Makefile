
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
	@echo "Setup"
	cp .env.dist .env

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

# BUILD AUTOGENERATED

build: build-english_forward build-english_reverse
	@echo "Building all"

build-english_forward:
	@echo "Building English Forward"
	$(call compile_all,$(CONTRACTS_PATH),EnglishForwardAuction)

build-english_reverse:
	@echo "Building English Reverse"
	$(call compile_all,$(CONTRACTS_PATH),EnglishReverseAuction)


# TESTS AUTOGENERATED

tests: tests-english_forward tests-english_reverse
	@echo "Testing all"

tests-english_forward:
	@echo "Testing English Forward"
	cd test/ts4 && python3 -m unittest english_forward.EnglishForwardAuctionTest && cd ../..

tests-english_reverse:
	@echo "Testing English Reverse"
	cd test/ts4 && python3 -m unittest english_reverse.EnglishReverseAuctionTest && cd ../..


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

