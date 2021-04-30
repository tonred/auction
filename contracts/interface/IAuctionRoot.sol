pragma ton-solidity >= 0.37.0;

import "../Lib.sol";


interface IAuctionRoot {
    function finish(
        AuctionType auctionType,
        uint64 id,
        Bid winner,
        address finishAddress,
        TvmCell finishPayload
    ) external;

    function deployEnglishForwardAuction(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) external;

    function deployEnglishForwardAuctionCustom(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) external;

    function deployEnglishReverseAuction(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) external;

    function deployEnglishReverseAuctionCustom(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) external;

    function deployDutchForwardAuction(
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) external;

    function deployDutchForwardAuctionCustom(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) external;


    function deployDutchReverseAuction(
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) external;

    function deployDutchReverseAuctionCustom(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) external;

    function deployBlindForwardAuction(
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) external;

    function deployBlindForwardAuctionCustom(
        address owner,
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) external;

    function deployBlindReverseAuction(
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) external;

    function deployBlindReverseAuctionCustom(
        address owner,
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration
    ) external;

}


