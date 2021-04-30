pragma ton-solidity >= 0.37.0;

interface IAuctionDeployedCallback {
    function onAuctionDeployed(address auction, uint64 id) external;
}
