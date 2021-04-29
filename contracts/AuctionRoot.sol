pragma ton-solidity >= 0.37.0;

import "BlindForwardAuction.sol";
import "BlindReverseAuction.sol";
import "DutchForwardAuction.sol";
import "DutchReverseAuction.sol";
import "EnglishForwardAuction.sol";
import "EnglishReverseAuction.sol";


contract AuctionRoot {
    uint128 _deployValue = 1 ton;
    uint128 _defaultFeeValue = 1 ton;
    uint128 _defaultDepositValue = 10 ton;


    TvmCell _codeEnglishForwardAuction;
    TvmCell _codeEnglishReverseAuction;
    TvmCell _codeDutchForwardAuction;
    TvmCell _codeDutchReverseAuction;
    TvmCell _codeBlindForwardAuction;
    TvmCell _codeBlindReverseAuction;
    TvmCell _codeBlindBid;

    bool _inited = false;
    uint64 _counter = 0;


    modifier inited() {
        require(_inited == true, Errors.IS_NOT_INITED);
        _;
    }

    modifier notInited() {
        require(_inited == false, Errors.IS_ALREADY_INITED);
        _;
    }

    modifier checkValue() {
        require(msg.value >= _deployValue, Errors.LOW_DEPLOY_VALUE);
        _;
    }


    constructor(uint128 deployValue, uint128 defaultFeeValue, uint128 defaultDepositValue) public {
        tvm.accept();
        _deployValue = deployValue;
        _defaultFeeValue = defaultFeeValue;
        _defaultDepositValue = defaultDepositValue;
    }


    function setCodeEnglishForwardAuction(
        TvmCell codeEnglishForwardAuction
    ) notInited public {
        tvm.accept();
        _codeEnglishForwardAuction = codeEnglishForwardAuction;
    }

    function setCodeEnglishReverseAuction(
        TvmCell codeEnglishReverseAuction
    ) notInited public {
        tvm.accept();
        _codeEnglishReverseAuction = codeEnglishReverseAuction;
    }

    function setCodeDutchForwardAuction(
        TvmCell codeDutchForwardAuction
    ) notInited public {
        tvm.accept();
        _codeDutchForwardAuction = codeDutchForwardAuction;
    }

    function setCodeDutchReverseAuction(
        TvmCell codeDutchReverseAuction
    ) notInited public {
        tvm.accept();
        _codeDutchReverseAuction = codeDutchReverseAuction;
    }

    function setCodeBlindForwardAuction(
        TvmCell codeBlindForwardAuction
    ) notInited public {
        tvm.accept();
        _codeBlindForwardAuction = codeBlindForwardAuction;
    }

    function setCodeBlindReverseAuction(
        TvmCell codeBlindReverseAuction
    ) notInited public {
        tvm.accept();
        _codeBlindReverseAuction = codeBlindReverseAuction;
    }

    function setCodeBlindBid(
        TvmCell codeBlindBid
    ) notInited public {
        tvm.accept();
        _codeBlindBid = codeBlindBid;
    }

    function finishInit() notInited public {
        require(  // Check if all 6 auctions codes are inited
            _isNotEmpty(_codeEnglishForwardAuction) && _isNotEmpty(_codeEnglishReverseAuction) &&
            _isNotEmpty(_codeDutchForwardAuction) && _isNotEmpty(_codeDutchReverseAuction) &&
            _isNotEmpty(_codeBlindForwardAuction) && _isNotEmpty(_codeBlindReverseAuction) &&
            _isNotEmpty(_codeBlindBid),
            Errors.AUCTIONS_CODES_NOT_INITED
        );
        tvm.accept();
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
    ) virtual checkValue inited public returns (address) {
        return deployEnglishForwardAuctionCustom(_defaultFeeValue, startValue, stepValue, startTime, openDuration);
    }

    // ENGLISH FORWARD
    function deployEnglishForwardAuctionCustom(
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) checkValue inited public returns (address) {
        TvmCell stateInit = buildEnglishForwardStateInit(_counter++);
        EnglishForwardAuction _auction = new EnglishForwardAuction{
            stateInit: stateInit,
            value: _deployValue
        }(fee, startValue, stepValue, startTime, openDuration);
        return _auction;
    }

    // ENGLISH FORWARD
    function buildEnglishForwardStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: EnglishForwardAuction,
            varInit: {
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
    ) virtual checkValue inited public returns (address) {
        return deployEnglishReverseAuctionCustom(_defaultFeeValue, startValue, stepValue, startTime, openDuration);
    }

    // ENGLISH REVERSE
    function deployEnglishReverseAuctionCustom(
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) checkValue inited public returns (address) {
        TvmCell stateInit = buildEnglishReverseStateInit(_counter++);
        EnglishReverseAuction _auction = new EnglishReverseAuction{
            stateInit: stateInit,
            value: _deployValue
        }(fee, startValue, stepValue, startTime, openDuration);
        return _auction;
    }

    // ENGLISH REVERSE
    function buildEnglishReverseStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: EnglishReverseAuction,
            varInit: {
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
    ) virtual checkValue inited public returns (address) {
        return deployDutchForwardAuctionCustom(_defaultFeeValue, startValue, finishValue, startTime, openDuration);
    }

    // DUTCH FORWARD
    function deployDutchForwardAuctionCustom(
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) checkValue inited public returns (address) {
        TvmCell stateInit = buildDutchForwardStateInit(_counter++);
        DutchForwardAuction _auction = new DutchForwardAuction{
            stateInit: stateInit,
            value: _deployValue
        }(fee, startValue, finishValue, startTime, openDuration);
        return _auction;
    }

    // DUTCH FORWARD
    function buildDutchForwardStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: DutchForwardAuction,
            varInit: {
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
    ) virtual checkValue inited public returns (address) {
        return deployDutchReverseAuctionCustom(_defaultFeeValue, startValue, finishValue, startTime, openDuration);
    }

    // DUTCH REVERSE
    function deployDutchReverseAuctionCustom(
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) checkValue inited public returns (address) {
        TvmCell stateInit = buildDutchReverseStateInit(_counter++);
        DutchReverseAuction _auction = new DutchReverseAuction{
            stateInit: stateInit,
            value: _deployValue
        }(fee, startValue, finishValue, startTime, openDuration);
        return _auction;
    }

    // DUTCH REVERSE
    function buildDutchReverseStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: DutchReverseAuction,
            varInit: {
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
    ) virtual checkValue inited public returns (address) {
        return deployBlindForwardAuctionCustom(_defaultFeeValue, _defaultDepositValue, startTime, openDuration, confirmationDuration);
    }

    // BLIND FORWARD
    function deployBlindForwardAuctionCustom(
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) checkValue inited public returns (address) {
        TvmCell stateInit = buildBlindForwardStateInit(_counter++);
        BlindForwardAuction _auction = new BlindForwardAuction{
            stateInit: stateInit,
            value: _deployValue
        }(fee, deposit, startTime, openDuration, confirmationDuration, _codeBlindBid);
        return _auction;
    }

    // BLIND FORWARD
    function buildBlindForwardStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: BlindForwardAuction,
            varInit: {
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
    ) virtual checkValue inited public returns (address) {
        return deployBlindReverseAuctionCustom(_defaultFeeValue, _defaultDepositValue, startTime, openDuration, confirmationDuration);
    }

    // BLIND REVERSE
    function deployBlindReverseAuctionCustom(
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) checkValue inited public returns (address) {
        TvmCell stateInit = buildBlindReverseStateInit(_counter++);
        BlindReverseAuction _auction = new BlindReverseAuction{
            stateInit: stateInit,
            value: _deployValue
        }(fee, deposit, startTime, openDuration, confirmationDuration, _codeBlindBid);
        return _auction;
    }

    // BLIND REVERSE
    function buildBlindReverseStateInit(uint64 id) public view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: BlindReverseAuction,
            varInit: {
                _root: address(this),
                _id: id
            },
            code: _codeBlindReverseAuction
        });
    }

}
