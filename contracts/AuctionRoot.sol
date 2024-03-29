pragma ton-solidity >= 0.37.0;

import "BlindForwardAuction.sol";
import "BlindReverseAuction.sol";
import "DutchForwardAuction.sol";
import "DutchReverseAuction.sol";
import "EnglishForwardAuction.sol";
import "EnglishReverseAuction.sol";
import "./interface/IAuctionRoot.sol";
import "./interface/IAuctionFinishCallback.sol";
import "./interface/IAuctionDeployedCallback.sol";


contract AuctionRoot is IAuctionRoot {
    uint8 constant SEND_ALL_GAS = 64;


    uint128 public _deployValue;
    uint128 public _defaultFeeValue;
    uint128 public _defaultDepositValue;

    TvmCell _codeEnglishForwardAuction;
    TvmCell _codeEnglishReverseAuction;
    TvmCell _codeDutchForwardAuction;
    TvmCell _codeDutchReverseAuction;
    TvmCell _codeBlindForwardAuction;
    TvmCell _codeBlindReverseAuction;
    TvmCell _codeBlindBid;

    bool _inited = false;
    uint64 public _counter = 0;


    /*************
     * MODIFIERS *
     *************/

    modifier inited() {
        require(_inited == true, Errors.IS_NOT_INITED);
        _;
    }

    modifier notInited() {
        require(_inited == false, Errors.IS_ALREADY_INITED);
        tvm.accept();
        _;
    }

    modifier checkValue() {
        require(msg.value >= _deployValue, Errors.LOW_DEPLOY_VALUE);
        _;
    }


     /*********
     * EVENTS *
     *********/

    event NewAuctionDeployed(uint64 id, address auction, AuctionType auctionType, address owner, uint32 openDuration);


    /***************
     * CONSTRUCTOR *
     **************/

    constructor(uint128 deployValue, uint128 defaultFeeValue, uint128 defaultDepositValue) public {
        tvm.accept();
        _deployValue = deployValue;
        _defaultFeeValue = defaultFeeValue;
        _defaultDepositValue = defaultDepositValue;
    }


    /*************
     * SET CODES *
     ************/

    function setCodeEnglishForwardAuction(TvmCell code) notInited public {
        _codeEnglishForwardAuction = code;
    }

    function setCodeEnglishReverseAuction(TvmCell code) notInited public {
        _codeEnglishReverseAuction = code;
    }

    function setCodeDutchForwardAuction(TvmCell code) notInited public {
        _codeDutchForwardAuction = code;
    }

    function setCodeDutchReverseAuction(TvmCell code) notInited public {
        _codeDutchReverseAuction = code;
    }

    function setCodeBlindForwardAuction(TvmCell code) notInited public {
        _codeBlindForwardAuction = code;
    }

    function setCodeBlindReverseAuction(TvmCell code) notInited public {
        _codeBlindReverseAuction = code;
    }

    function setCodeBlindBid(TvmCell code) notInited public {
        _codeBlindBid = code;
    }

    // Called once, when all auction codes is set
    function finishInit() notInited public {
        require(  // Check if all 6 auctions codes are inited
            _isNotEmpty(_codeEnglishForwardAuction) && _isNotEmpty(_codeEnglishReverseAuction) &&
            _isNotEmpty(_codeDutchForwardAuction) && _isNotEmpty(_codeDutchReverseAuction) &&
            _isNotEmpty(_codeBlindForwardAuction) && _isNotEmpty(_codeBlindReverseAuction) &&
            _isNotEmpty(_codeBlindBid),
            Errors.AUCTIONS_CODES_NOT_INITED
        );
        _inited = true;
    }

    function _isNotEmpty(TvmCell cell) private pure returns (bool) {
        return cell.depth() > 0;
    }


    // ENGLISH FORWARD
    function deployEnglishForwardAuction(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public override {
        deployEnglishForwardAuctionCustom(
            msg.sender,
            _defaultFeeValue,
            startValue,
            stepValue,
            startTime,
            openDuration
        );
    }

    // ENGLISH FORWARD
    function deployEnglishForwardAuctionCustom(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public override checkValue inited {
        reserve(0);
        TvmCell stateInit = buildEnglishForwardStateInit(_counter++);
        address auction = new EnglishForwardAuction{
            stateInit: stateInit,
            value: _deployValue
        }(owner, fee, startValue, stepValue, startTime, openDuration);
        emit NewAuctionDeployed(_counter, auction, AuctionType.ENGLISH_FORWARD, msg.sender, openDuration);
        IAuctionDeployedCallback(msg.sender).onAuctionDeployed{value: 0, flag: 128, bounce: false}(auction, _counter);
    }

    // ENGLISH FORWARD
    function buildEnglishForwardStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: EnglishForwardAuction,
            varInit: {
                _type: AuctionType.ENGLISH_FORWARD,
                _root: address(this),
                _id: id
            },
            code: _codeEnglishForwardAuction
        });
    }


    // ENGLISH REVERSE
    function deployEnglishReverseAuction(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public override {
        deployEnglishReverseAuctionCustom(
            msg.sender,
            _defaultFeeValue,
            startValue,
            stepValue,
            startTime,
            openDuration
        );
    }

    // ENGLISH REVERSE
    function deployEnglishReverseAuctionCustom(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public override checkValue inited {
        reserve(0);
        TvmCell stateInit = buildEnglishReverseStateInit(_counter++);
        address auction = new EnglishReverseAuction{
            stateInit: stateInit,
            value: _deployValue
        }(owner, fee, startValue, stepValue, startTime, openDuration);
        emit NewAuctionDeployed(_counter, auction, AuctionType.ENGLISH_REVERSE, msg.sender, openDuration);
        IAuctionDeployedCallback(msg.sender).onAuctionDeployed{value: 0, flag: 128, bounce: false}(auction, _counter);
    }

    // ENGLISH REVERSE
    function buildEnglishReverseStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: EnglishReverseAuction,
            varInit: {
                _type: AuctionType.ENGLISH_REVERSE,
                _root: address(this),
                _id: id
            },
            code: _codeEnglishReverseAuction
        });
    }


    // DUTCH FORWARD
    function deployDutchForwardAuction(
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) public override {
        deployDutchForwardAuctionCustom(
            msg.sender,
            _defaultFeeValue,
            startValue,
            finishValue,
            startTime,
            openDuration
        );
    }

    // DUTCH FORWARD
    function deployDutchForwardAuctionCustom(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) public override checkValue inited {
        reserve(0);
        TvmCell stateInit = buildDutchForwardStateInit(_counter++);
        address auction = new DutchForwardAuction{
            stateInit: stateInit,
            value: _deployValue
        }(owner, fee, startValue, finishValue, startTime, openDuration);
        emit NewAuctionDeployed(_counter, auction, AuctionType.DUTCH_FORWARD, msg.sender, openDuration);
        IAuctionDeployedCallback(msg.sender).onAuctionDeployed{value: 0, flag: 128, bounce: false}(auction, _counter);
    }

    // DUTCH FORWARD
    function buildDutchForwardStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: DutchForwardAuction,
            varInit: {
                _type: AuctionType.DUTCH_FORWARD,
                _root: address(this),
                _id: id
            },
            code: _codeDutchForwardAuction
        });
    }


    // DUTCH REVERSE
    function deployDutchReverseAuction(
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) public override {
        deployDutchReverseAuctionCustom(
            msg.sender,
            _defaultFeeValue,
            startValue,
            finishValue,
            startTime,
            openDuration
        );
    }

    // DUTCH REVERSE
    function deployDutchReverseAuctionCustom(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) public override checkValue inited {
        reserve(0);
        TvmCell stateInit = buildDutchReverseStateInit(_counter++);
        address auction = new DutchReverseAuction{
            stateInit: stateInit,
            value: _deployValue
        }(owner, fee, startValue, finishValue, startTime, openDuration);
        emit NewAuctionDeployed(_counter, auction, AuctionType.DUTCH_REVERSE, msg.sender, openDuration);
        IAuctionDeployedCallback(msg.sender).onAuctionDeployed{value: 0, flag: 128, bounce: false}(auction, _counter);
    }

    // DUTCH REVERSE
    function buildDutchReverseStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: DutchReverseAuction,
            varInit: {
                _type: AuctionType.DUTCH_REVERSE,
                _root: address(this),
                _id: id
            },
            code: _codeDutchReverseAuction
        });
    }


    // BLIND FORWARD
    function deployBlindForwardAuction(
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) public override {
        deployBlindForwardAuctionCustom(
            msg.sender,
            _defaultFeeValue,
            _defaultDepositValue,
            startTime,
            openDuration,
            confirmationDuration
        );
    }

    // BLIND FORWARD
    function deployBlindForwardAuctionCustom(
        address owner,
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) public override checkValue inited {
        reserve(0);
        TvmCell stateInit = buildBlindForwardStateInit(_counter++);
        address auction = new BlindForwardAuction{
            stateInit: stateInit,
            value: _deployValue
        }(owner, fee, deposit, startTime, openDuration, confirmationDuration, _codeBlindBid);
        emit NewAuctionDeployed(_counter, auction, AuctionType.BLIND_FORWARD, msg.sender, openDuration);
        IAuctionDeployedCallback(msg.sender).onAuctionDeployed{value: 0, flag: 128, bounce: false}(auction, _counter);
    }

    // BLIND FORWARD
    function buildBlindForwardStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: BlindForwardAuction,
            varInit: {
                _type: AuctionType.BLIND_FORWARD,
                _root: address(this),
                _id: id
            },
            code: _codeBlindForwardAuction
        });
    }


    // BLIND REVERSE
    function deployBlindReverseAuction(
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) public override {
        deployBlindReverseAuctionCustom(
            msg.sender,
            _defaultFeeValue,
            _defaultDepositValue,
            startTime,
            openDuration,
            confirmationDuration
        );

    }

    // BLIND REVERSE
    function deployBlindReverseAuctionCustom(
        address owner,
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) public override checkValue inited {
        reserve(0);
        TvmCell stateInit = buildBlindReverseStateInit(_counter++);
        address auction = new BlindReverseAuction{
            stateInit: stateInit,
            value: _deployValue
        }(owner, fee, deposit, startTime, openDuration, confirmationDuration, _codeBlindBid);
        emit NewAuctionDeployed(_counter, auction, AuctionType.BLIND_REVERSE, msg.sender, openDuration);
        IAuctionDeployedCallback(msg.sender).onAuctionDeployed{value: 0, flag: 128, bounce: false}(auction, _counter);
    }

    // BLIND REVERSE
    function buildBlindReverseStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: BlindReverseAuction,
            varInit: {
                _type: AuctionType.BLIND_REVERSE,
                _root: address(this),
                _id: id
            },
            code: _codeBlindReverseAuction
        });
    }


     /*****************
     * FINISH METHODS *
     *****************/

    function finish(
        AuctionType auctionType,
        uint64 id,
        Bid winner,
        address finishAddress,
        TvmCell finishPayload
    ) override public {
        _checkIsAuctionCallback(auctionType, id);
        IAuctionFinishCallback(finishAddress).onAuctionFinish{value: 0, flag: SEND_ALL_GAS, bounce: false}
            (id, msg.sender, winner.owner, winner.value, finishPayload);
    }

    function _checkIsAuctionCallback(AuctionType auctionType, uint64 id) internal view {
        address auctionAddress = _calcAuctionAddress(auctionType, id);
        require(msg.sender == auctionAddress, Errors.IS_NOT_FROM_AUCTION);
    }

    function _calcAuctionAddress(AuctionType auctionType, uint64 id) internal view returns (address) {
        TvmCell stateInit;
        if (auctionType == AuctionType.ENGLISH_FORWARD) stateInit = buildEnglishForwardStateInit(id);
        if (auctionType == AuctionType.ENGLISH_REVERSE) stateInit = buildEnglishReverseStateInit(id);
        if (auctionType == AuctionType.DUTCH_FORWARD) stateInit = buildDutchForwardStateInit(id);
        if (auctionType == AuctionType.DUTCH_REVERSE) stateInit = buildDutchReverseStateInit(id);
        if (auctionType == AuctionType.BLIND_FORWARD) stateInit = buildBlindForwardStateInit(id);
        if (auctionType == AuctionType.BLIND_REVERSE) stateInit = buildBlindReverseStateInit(id);
        return _calcAddress(stateInit);
    }

    function _calcAddress(TvmCell stateInit) private pure returns (address) {
        return address.makeAddrStd(0, tvm.hash(stateInit));
    }

     function reserve(uint128 additional) private view {
        tvm.rawReserve(address(this).balance - msg.value + additional, 2);
    }

}
