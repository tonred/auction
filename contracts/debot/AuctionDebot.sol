pragma ton-solidity >= 0.39.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "common/Debot.sol";
import "common/Terminal.sol";
import "common/AddressInput.sol";
import "common/AmountInput.sol";
import "common/Sdk.sol";
import "common/Menu.sol";
import "../AuctionRoot.sol";
import "../BlindForwardAuction.sol";
import "../abstract/BlindAuction.sol";
import "../BlindReverseAuction.sol";
import "../DutchForwardAuction.sol";
import "../DutchReverseAuction.sol";
import "../EnglishForwardAuction.sol";
import "../EnglishReverseAuction.sol";
import "../abstract/BaseAuction.sol";


interface IMultisig {
    function submitTransaction(
        address dest,
        uint128 value,
        bool bounce,
        bool allBalance,
        TvmCell payload)
    external;
}

contract AuctionDebot is Debot {

    address auctionRootAddress;
    address _addrMultisig;

    uint128 bidValue;
    uint256 bidSalt;

    uint128 auctionTypeChoice;
    address auctionAddressInput;
    uint32 auctionOpenDuration;
    uint32 auctionConfirmationDuration;
    optional(uint256) pubkey;
    uint32 auctionStepValue;
    uint32 auctionFinishValue;
    uint128 auctionStartValue;

    constructor(string debotAbi, address targetAddress) public {
        require(tvm.pubkey() == msg.pubkey(), 100);
        tvm.accept();
        init(DEBOT_ABI, debotAbi, '', targetAddress);
        auctionRootAddress = address.makeAddrStd(0, 0x739f8b3a124de1ff4ce40948fa661e8477d0c1193b6de13171f19a52e1df014b);
    }

    function getVersion() public override returns (string name, uint24 semver) {
        (name, semver) = ("Auction TONRED Debot", 4 << 8);
    }

    function fetch() public override returns (Context[] contexts) {}

    function start() public override {
        Terminal.print(0, "Hello, I am a Auction debot!");
        AddressInput.get(tvm.functionId(saveRootAddress), "Input Root Address: ");
    }

    function saveRootAddress(address value) public {
        auctionRootAddress = value;
        _start();
    }

    function _start() private {
        Menu.select("\nMain menu", "Select operation:", [
            MenuItem("Set Multisig", "", tvm.functionId(getMultisigMenu)),
            MenuItem("Create auction", "", tvm.functionId(getCreateAuctionMenu)),
            MenuItem("Make bid", "", tvm.functionId(getMakeBidMenu)),
            MenuItem("Exit", "", 0)
        ]);
    }

    function getCreateAuctionMenu(uint32 index) public {
        index;
        Menu.select("", "Choice auction type:", [
            MenuItem("English Forward", "", tvm.functionId(choiceAuctionTypeCreateAuction)),
            MenuItem("English Reverse", "", tvm.functionId(choiceAuctionTypeCreateAuction)),
            MenuItem("Dutch Forward", "", tvm.functionId(choiceAuctionTypeCreateAuction)),
            MenuItem("Dutch Reverse", "", tvm.functionId(choiceAuctionTypeCreateAuction)),
            MenuItem("Blind Forward", "", tvm.functionId(choiceAuctionTypeCreateAuction)),
            MenuItem("Blind Reverse", "", tvm.functionId(choiceAuctionTypeCreateAuction)),
            MenuItem("Exit", "", 0)
            ]);
    }

    function getMakeBidMenu(uint32 index) public {
        index;
        Menu.select("", "Choice auction type:", [
            MenuItem("English Forward", "", tvm.functionId(choiceAuctionTypeMakeBid)),
            MenuItem("English Reverse", "", tvm.functionId(choiceAuctionTypeMakeBid)),
            MenuItem("Dutch Forward", "", tvm.functionId(choiceAuctionTypeMakeBid)),
            MenuItem("Dutch Reverse", "", tvm.functionId(choiceAuctionTypeMakeBid)),
            MenuItem("Blind Forward", "", tvm.functionId(choiceAuctionTypeMakeBid)),
            MenuItem("Blind Reverse", "", tvm.functionId(choiceAuctionTypeMakeBid)),
            MenuItem("Exit", "", 0)
            ]);
    }

    function choiceAuctionTypeMakeBid(uint32 index) public {
        auctionTypeChoice = index;
        AddressInput.get(tvm.functionId(saveAuctionAddress), "Type Auction address: ");
    }

    function saveAuctionAddress(address value) public {
        auctionAddressInput = value;
        AmountInput.get(tvm.functionId(getAuctionBuyEnterBidValue), "Enter Bid Value: ", 0, 1, 100000);
    }


    function getMultisigMenu(uint32 index) public {
        index;
        AddressInput.get(tvm.functionId(saveMultisig), "Type Multisig address");
    }

    function saveMultisig(address value) public {
        _addrMultisig = value;
        _start();
    }


    function choiceAuctionTypeCreateAuction(uint32 index) public {
        auctionTypeChoice = index;
        if (auctionTypeChoice == 0 /*EnglishForward*/) {
            AmountInput.get(tvm.functionId(choiceAuctionStartValue), "Enter start value: ", 0, 1, 100);
        }
        else if (auctionTypeChoice == 1 /*EnglishReverse*/) {
            AmountInput.get(tvm.functionId(choiceAuctionStartValue), "Enter start value: ", 0, 1, 100);
        }
        else if (auctionTypeChoice == 2 /*DutchForward*/) {
            AmountInput.get(tvm.functionId(choiceAuctionStartValue), "Enter start value: ", 0, 1, 100);

        }
        else if (auctionTypeChoice == 3 /*DutchReverse*/) {
            AmountInput.get(tvm.functionId(choiceAuctionStartValue), "Enter start value: ", 0, 1, 100);
        }
        else if (auctionTypeChoice == 4 /*BlindForward*/) {
            AmountInput.get(tvm.functionId(choiceConfirmationDuration), "Enter confirmation duration: ", 0, 1, 1 << 32);

        }
        else if (auctionTypeChoice == 5 /*BlindReverse*/) {
            AmountInput.get(tvm.functionId(choiceConfirmationDuration), "Enter confirmation duration: ", 1, 1, 1 << 32);
        }
    }

    function choiceAuctionStartValue(uint128 value) public{
        auctionStartValue = value;
        if (auctionTypeChoice == 2 || auctionTypeChoice == 3){
            AmountInput.get(tvm.functionId(choiceAuctionFinishValue), "Enter finish value: ", 0, 1, 100);
        }
        else {
            AmountInput.get(tvm.functionId(choiceAuctionStepValue), "Enter step value: ", 0, 1, 100);
        }
    }

    function choiceAuctionOpenDuration(uint32 value) public {
        auctionOpenDuration = value;

        if (auctionTypeChoice == 0 /*EnglishForward*/){
            Terminal.print(tvm.functionId(deployEnglishForward), "Deploying!");
        }
        else if (auctionTypeChoice == 1 /*EnglishReverse*/){
            Terminal.print(tvm.functionId(deployEnglishReverse), "Deploying!");
        }
        else if (auctionTypeChoice == 2 /*DutchForward*/){
            Terminal.print(tvm.functionId(deployDutchForward), "Deploying!");
        }
        else if (auctionTypeChoice == 3 /*DutchReverse*/){
            Terminal.print(tvm.functionId(deployDutchReverse), "Deploying!");
        }
        else if (auctionTypeChoice == 4 /*BlindForward*/){
            Terminal.print(tvm.functionId(deployBlindForward), "Deploying!");
        }
        else if (auctionTypeChoice == 5 /*BlindReverse*/){
            Terminal.print(tvm.functionId(deployBlindReverse), "Deploying!");
        }
    }

    function choiceConfirmationDuration(uint32 value) public {
        auctionConfirmationDuration = value;
        AmountInput.get(tvm.functionId(choiceAuctionOpenDuration), "Enter open duration: ", 0, 1, 1 << 32);
    }

    function choiceAuctionStepValue(uint32 value) public {
        auctionStepValue = value;
        AmountInput.get(tvm.functionId(choiceAuctionOpenDuration), "Enter open duration: ", 0, 1, 1 << 32);
    }

    function choiceAuctionFinishValue(uint32 value) public {
        auctionFinishValue = value;
        AmountInput.get(tvm.functionId(choiceAuctionOpenDuration), "Enter open duration: ", 0, 1, 1 << 32);
    }

    function onSuccess(uint64 transId) public {
        transId;
        Terminal.print(0, "Succeded");
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        sdkError = sdkError;
        exitCode = exitCode;
        Terminal.print(0, format("Operation failed: {} {}", sdkError, exitCode));
    }

    function deployEnglishForward() public {
        Terminal.print(0, format("Your address: {}", _addrMultisig));
        TvmCell body = tvm.encodeBody(AuctionRoot.deployEnglishForwardAuction, auctionStartValue * 1 ton, auctionStepValue * 1 ton, now, auctionOpenDuration);
        IMultisig(_addrMultisig).submitTransaction{
            abiVer : 2,
            extMsg : true,
            sign : true,
            pubkey : pubkey,
            time : uint64(now),
            expire : 0,
            callbackId : tvm.functionId(onSuccess),
            onErrorId : tvm.functionId(onError)
        }(auctionRootAddress, 2 ton, true, false, body);
        _start();
    }

    function deployEnglishReverse() public {
        TvmCell body = tvm.encodeBody(AuctionRoot.deployEnglishReverseAuction, auctionStartValue * 1 ton, auctionStepValue * 1 ton, now, auctionOpenDuration);
        IMultisig(_addrMultisig).submitTransaction{
            abiVer : 2,
            extMsg : true,
            sign : true,
            pubkey : pubkey,
            time : uint64(now),
            expire : 0,
            callbackId : 0,
            onErrorId : tvm.functionId(onError)
        }(auctionRootAddress, 2 ton, true, false, body);
        _start();
    }


    function deployDutchForward() public {
        TvmCell body = tvm.encodeBody(AuctionRoot.deployDutchForwardAuction, auctionStartValue * 1 ton, auctionStepValue * 1 ton, now, auctionOpenDuration);
        IMultisig(_addrMultisig).submitTransaction{
            abiVer : 2,
            extMsg : true,
            sign : true,
            pubkey : pubkey,
            time : uint64(now),
            expire : 0,
            callbackId : 0,
            onErrorId : tvm.functionId(onError)
        }(auctionRootAddress, 2 ton, true, false, body);
        _start();
    }


    function deployDutchReverse() public {
        TvmCell body = tvm.encodeBody(AuctionRoot.deployDutchReverseAuction, auctionStartValue * 1 ton, auctionStepValue * 1 ton, now, auctionOpenDuration);
        IMultisig(_addrMultisig).submitTransaction{
            abiVer : 2,
            extMsg : true,
            sign : true,
            pubkey : pubkey,
            time : uint64(now),
            expire : 0,
            callbackId : 0,
            onErrorId : tvm.functionId(onError)
        }(auctionRootAddress, 2 ton, true, false, body);
        _start();
    }

    function deployBlindForward() public {
        TvmCell body = tvm.encodeBody(AuctionRoot.deployBlindForwardAuction, now, auctionOpenDuration, auctionConfirmationDuration);
        IMultisig(_addrMultisig).submitTransaction{
            abiVer : 2,
            extMsg : true,
            sign : true,
            pubkey : pubkey,
            time : uint64(now),
            expire : 0,
            callbackId : 0,
            onErrorId : tvm.functionId(onError)
        }(auctionRootAddress, 2 ton, true, false, body);
        _start();
    }


    function deployBlindReverse() public {
        TvmCell body = tvm.encodeBody(AuctionRoot.deployBlindReverseAuction, now, auctionOpenDuration, auctionConfirmationDuration);
        IMultisig(_addrMultisig).submitTransaction{
            abiVer : 2,
            extMsg : true,
            sign : true,
            pubkey : pubkey,
            time : uint64(now),
            expire : 0,
            callbackId : 0,
            onErrorId : tvm.functionId(onError)
        }(auctionRootAddress, 2 ton, true, false, body);
        _start();
    }
//    function choiceAuctionType(address value) public {
//
//    }

    function getAuctionBuyEnterBidValue(uint128 value) public {
        Terminal.print(0, format("{}", value));
        bidValue = value * 1 ton;
        Terminal.print(0, format("{}", bidValue));
        if (auctionTypeChoice == 4 || auctionTypeChoice == 5 /*BlindForward*/ /*BlindReverse*/) {
            uint256 salt = rnd.next();
            bidSalt = salt;
            Terminal.print(0, format("Your salt: {} \n REMIND IT!", salt));
            uint256 bidHash = calcHash(bidValue, bidSalt);
            Terminal.print(0, format("Your bidHash: {}", bidHash));
            TvmCell body = tvm.encodeBody(BlindAuction.makeBid, bidHash);
            IMultisig(_addrMultisig).submitTransaction{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: 0,
                onErrorId: 0
            }(auctionAddressInput, 2 ton, true, true, body);
        } else if (auctionTypeChoice == 3 /*DutchReverse*/) {
            TvmCell body = tvm.encodeBody(DutchReverseAuction.buy, bidValue);
            IMultisig(_addrMultisig).submitTransaction{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: 0,
                onErrorId: 0
            }(auctionAddressInput, 2 ton, true, true, body);
        } else if (auctionTypeChoice == 2 /*DutchForward*/) {
            TvmCell body = tvm.encodeBody(DutchForwardAuction.buy, bidValue);
            IMultisig(_addrMultisig).submitTransaction{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: 0,
                onErrorId: 0
            }(auctionAddressInput, bidValue + 2 ton, true, true, body);
        } else if (auctionTypeChoice == 1 /*EnglishReverse*/) {
            TvmCell body = tvm.encodeBody(EnglishReverseAuction.makeBid, bidValue);
            IMultisig(_addrMultisig).submitTransaction{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: 0,
                onErrorId: 0
            }(auctionAddressInput, 2 ton, true, true, body);
        } else if (auctionTypeChoice == 0 /*EnglishForward*/) {
            TvmCell body = tvm.encodeBody(EnglishForwardAuction.makeBid, bidValue);
            IMultisig(_addrMultisig).submitTransaction{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: 0,
                onErrorId: 0
            }(auctionAddressInput, bidValue + 2 ton, true, true, body);
        }
        _start();
    }


    function quit() public override {
    }

    function calcHash(uint128 bidValue, uint256 salt) public pure returns (uint256) {
        TvmBuilder builder;
        builder.store(bidValue, salt);
        TvmCell cell = builder.toCell();
        return tvm.hash(cell);
    }

    function upgrade(TvmCell state) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        TvmCell newcode = state.toSlice().loadRef();
        tvm.accept();
        tvm.commit();
        tvm.setcode(newcode);
        tvm.setCurrentCode(newcode);
        onCodeUpgrade();
    }

    function onCodeUpgrade() private {}
}
