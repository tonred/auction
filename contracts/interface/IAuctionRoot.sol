pragma ton-solidity >= 0.37.0;

import "../Lib.sol";


interface IAuctionRoot {
    function finish(AuctionType auctionType, uint64 id, Bid winner, address finishAddress, TvmCell finishPayload) external;
}
