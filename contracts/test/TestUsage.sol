pragma ton-solidity >=0.39.0;

import "../interface/IAuctionFinishCallback.sol";
import "../interface/IAuctionDeployedCallback.sol";
import "../AuctionRoot.sol";


contract TestUsage is IAuctionFinishCallback, IAuctionDeployedCallback {

    address _auctionRoot;
    address _auctionContract;
    address _winner;

    event AuctionCompleted(address winner, uint128 value, TvmCell payload);

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
        AuctionRoot(_auctionRoot).deployEnglishForwardAuction{value: 1.1 ton}(1, 10, 10, 40);
    }

    function onAuctionDeployed(address auction, uint64 /*id*/) public override {
        _auctionContract = auction;
        TvmCell empty;
        BaseAuction(_auctionContract).setFinishPayload(address(this), empty);
    }

    function onAuctionFinish(uint64 /*auctionId*/, address /*auction*/, address winnerAddress, uint128 winnerValue, TvmCell payload) override public {
        require(msg.sender == _auctionRoot, 101);
        tvm.accept();
        _winner = winnerAddress;
        uint128 x = winnerValue;
        TvmCell y = payload;
        emit AuctionCompleted(winnerAddress, x, y);
    }


    fallback() external {}

    receive() external {}
}
