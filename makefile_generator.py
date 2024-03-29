import itertools

TEMPLATE = '''
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

	@echo "build-{{english/forward/blind}}-{{forward/reverse}} - compile only this auction contract"
	@echo "tests-{{english/forward/blind}}-{{forward/reverse}} - test only this auction contract"
	@echo "build-blind-bid - compile blind bid contract"
	@echo "build-test-auction-root: - build auction root contract for tests"
	@echo "{{build/tests}}-auction-root - build/test auction root contract"
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
	rm -f $(ARTIFACTS_PATH)/*.tvc \\
		  $(ARTIFACTS_PATH)/*.js \\
		  $(ARTIFACTS_PATH)/*.base64

clean-tmp:
	rm -f $(ARTIFACTS_PATH)/*.sh \\
		  $(ARTIFACTS_PATH)/*.result \\
		  $(ARTIFACTS_PATH)/*.code

dev: build tests
	@echo "dev"

debot: build-debot deploy-debot
	@echo "debot"

# BUILD AUTOGENERATED
{}

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
{}

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
build: {} build-blind-bid build-auction-root build-test-auction-root build-test-wallet build-test-usage build-test-deployer
	@echo "Building all"
'''

TESTS_ALL_TEMPLATE = '''
tests: {} tests-auction-root tests-workflow
	@echo "Testing all"
'''

AUCTIONS_TYPES = ('English', 'Dutch', 'Blind')
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
