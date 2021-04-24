pragma ton-solidity >= 0.37.0;

import "./abstract/BaseAuction.sol";
import "EnglishForwardAuction.sol";


contract AuctionRoot {
    uint128 constant DEPLOY_AUCTION_VALUE = 1 ton;


    TvmCell _englishForwardAuctionCode;

    uint64 _counter;


    constructor(TvmCell englishForwardAuctionCode) public {
        tvm.accept();
        _englishForwardAuctionCode = englishForwardAuctionCode;
    }

    function deployEnglishForwardAuction(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public returns (address) {
        TvmCell stateInit = _buildBidStateInit(EnglishForwardAuction, _englishForwardAuctionCode);
        EnglishForwardAuction _auction = new EnglishForwardAuction{
            stateInit: stateInit,
            value: DEPLOY_AUCTION_VALUE
        }(startValue, stepValue, startTime, openDuration);
        return _auction;
    }

    function _buildBidStateInit(BaseAuction auction, TvmCell code) private view returns (TvmCell) {
        uint64 id = _counter++;
        return _buildBidStateInitView(auction, code, id);
    }

    function _buildBidStateInitView(BaseAuction auction, TvmCell code, uint64 id) private view returns (TvmCell) {
        return tvm.buildStateInit({
            contr : auction,
            varInit : {
                _root : address(this),
                _id: id
            },
            code : code
        });
    }

}
