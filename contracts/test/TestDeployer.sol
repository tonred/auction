pragma ton-solidity >=0.39.0;

import "../interface/IAuctionDeployedCallback.sol";
import "../interface/IAuctionFinishCallback.sol";
import "../interface/IAuctionRoot.sol";


contract TestDeployer is IAuctionDeployedCallback, IAuctionFinishCallback {

    address _auctionRoot;
    mapping(uint64 => address) public deployedAuctions;
    mapping(uint64 => address) public finishedAuctions;


    constructor(address auctionRoot) public {
        tvm.accept();
        _auctionRoot = auctionRoot;
    }


    function deployAll(uint8 repeats, uint32 openDuration, uint32 confirmationDuration) public view {
        tvm.accept();
        IAuctionRoot auctionRoot = IAuctionRoot(_auctionRoot);
        for (uint8 i = 0; i < repeats; i++) {
            auctionRoot.deployEnglishForwardAuction{value: 5 ton}(1 ton, 1 ton, now, openDuration);
            auctionRoot.deployEnglishReverseAuction{value: 5 ton}(1 ton, 1 ton, now, openDuration);
            auctionRoot.deployDutchForwardAuction{value: 5 ton}(100 ton, 1 ton, now, openDuration);
            auctionRoot.deployDutchReverseAuction{value: 5 ton}(1 ton, 100 ton, now, openDuration);
            auctionRoot.deployBlindForwardAuction{value: 5 ton}(now, openDuration, confirmationDuration);
            auctionRoot.deployBlindReverseAuction{value: 5 ton}(now, openDuration, confirmationDuration);
        }

    }

    function onAuctionDeployed(address auction, uint64 id) public override {
        require(msg.sender == _auctionRoot, 999);
        deployedAuctions[id] = auction;
    }

    function onAuctionFinish(
        uint64 auctionId,
        address /*auction*/,
        address winnerAddress,
        uint128 /*winnerValue*/,
        TvmCell /*payload*/
    ) public override {
        require(msg.sender == _auctionRoot, 999);
        finishedAuctions[auctionId] = winnerAddress;
    }


}
