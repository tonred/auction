pragma ton-solidity >=0.39.0;

import "../interface/IAuctionFinishCallback.sol";
import "../AuctionRoot.sol";


contract TestUsage is IAuctionFinishCallback {

    address _auctionRoot;
    address _auctionContract;
    address _winner;


    constructor(address auctionRoot) public {
        tvm.accept();
        _auctionRoot = auctionRoot;
    }

    function getAuctionContract() public view returns (address) {
        return _auctionContract;
    }

    function getBestPerson() public view returns (address) {
        return _winner;
    }

    function createAuction() public view {
        tvm.accept();
        AuctionRoot(_auctionRoot).deployEnglishForwardAuction{
            value: 1.1 ton,
            callback: onAuctionCreated
        }(1, 10, 10, 40);
    }

    function onAuctionCreated(address auctionContract) public {
        _auctionContract = auctionContract;
        TvmCell empty;
        BaseAuction(_auctionContract).setFinishPayload(address(this), empty);
    }

    function onAuctionFinish(address winnerAddress, uint128 winnerValue, TvmCell payload) override public {
        require(msg.sender == _auctionRoot, 101);
        tvm.accept();
        _winner = winnerAddress;
        uint128 x = winnerValue;
        TvmCell y = payload;
    }


    fallback() external {}

    receive() external {}
}
