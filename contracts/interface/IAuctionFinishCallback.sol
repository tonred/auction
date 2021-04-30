pragma ton-solidity >= 0.37.0;

import "../Lib.sol";


interface IAuctionFinishCallback {
    function onAuctionFinish(
        uint64 auctionId,
        address auction,
        address winnerAddress,
        uint128 winnerValue,
        TvmCell payload
    ) external;
}
