import itertools

TEMPLATE = '''
include .env

ifndef VERBOSE
.SILENT:
endif

help:
	@echo "setup - setup .env file from sample"
	@echo "build - build {{input_dir}}/{{input_file}} file"
	@echo "clean - clear build artifacts except ABI's"
	@echo "clean-tmp - clear temp build artifacts except tvc and ABI's"

setup:
	@echo "Setup"
	cp .env.dist .env

create:
	@echo "Creating makefile"
	python3 makefile_generator.py

clean: clean-tmp
	rm -f $(ARTIFACTS_PATH)/*.tvc \\
		  $(ARTIFACTS_PATH)/*.js \\
		  $(ARTIFACTS_PATH)/*.base64

clean-tmp:
	rm -f $(ARTIFACTS_PATH)/*.sh \\
		  $(ARTIFACTS_PATH)/*.result \\
		  $(ARTIFACTS_PATH)/*.code

dev: build tests
	@echo "dev"

# BUILD AUTOGENERATED
{}

build-test-wallet:
	@echo "Compiling TestWallet"
	$(call compile_all,$(TEST_CONTRACTS_PATH),TestWallet)

# TESTS AUTOGENERATED
{}

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
	$(TVM_LINKER_BIN) compile $(ARTIFACTS_PATH)/$(1).code \\
							   --lib $(STDLIB_PATH) \\
							   --abi-json $(ARTIFACTS_PATH)/$(1).abi.json \\
							   -o $(ARTIFACTS_PATH)/$(1).tvc
endef

define compile_client_code
	node $(CLIENT_JS_COMPILER) $(1)
endef

define tvc_to_base64
	base64 $(1).tvc > $(1).base64
endef

'''

BUILD_TEMPLATE = '''
build-{}:
	@echo "Building {}"
	$(call compile_all,$(CONTRACTS_PATH),{})
'''

TESTS_TEMPLATE = '''
tests-{}:
	@echo "Testing {}"
	cd test/ts4 && python3 -m unittest {} && cd ../..
'''

BUILD_ALL_TEMPLATE = '''
build: {} build-test-wallet
	@echo "Building all"
'''

TESTS_ALL_TEMPLATE = '''
tests: {}
	@echo "Testing all"
'''

# AUCTIONS_TYPES = ('English', 'Dutch', 'Blind')
# AUCTIONS_DIRECTIONS = ('Forward', 'Reverse')
AUCTIONS_TYPES = ('English', 'Dutch')
AUCTIONS_DIRECTIONS = ('Forward', 'Reverse')


def generate_content() -> str:
    names = list()
    build_texts = list()
    tests_texts = list()
    for auction_type, auction_direction in itertools.product(AUCTIONS_TYPES, AUCTIONS_DIRECTIONS):
        name = auction_type.lower() + '-' + auction_direction.lower()
        display_text = auction_type + ' ' + auction_direction
        contract_file = auction_type + auction_direction + 'Auction'
        tests_module = name.replace('-', '_') + '.' + auction_type + auction_direction + 'AuctionTest'
        build = BUILD_TEMPLATE.format(name, display_text, contract_file)
        tests = TESTS_TEMPLATE.format(name, display_text, tests_module)
        names.append(name)
        build_texts.append(build)
        tests_texts.append(tests)
    build_all_calls = ' '.join(f'build-{name}' for name in names)
    tests_all_calls = ' '.join(f'tests-{name}' for name in names)
    build_texts.insert(0, BUILD_ALL_TEMPLATE.format(build_all_calls))
    tests_texts.insert(0, TESTS_ALL_TEMPLATE.format(tests_all_calls))
    build = ''.join(build_texts).strip()
    tests = ''.join(tests_texts).strip()
    return TEMPLATE.format(build, tests)


if __name__ == '__main__':
    content = generate_content()
    with open('Makefile', 'w') as makefile:
        makefile.write(content)
