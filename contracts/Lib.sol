pragma ton-solidity >=0.39.0;


enum Phase {WAIT, OPEN, CONFIRMATION, CLOSE}

struct PhaseTime {
    uint32 startTime;
    uint32 finishTime;
}

struct Bid {
    address owner;
    uint128 value;
}

enum AuctionType {
    ENGLISH_FORWARD, ENGLISH_REVERSE,
    DUTCH_FORWARD, DUTCH_REVERSE,
    BLIND_FORWARD, BLIND_REVERSE
}

library Errors {
    // Basic
    uint16 constant IS_NOT_ROOT = 101;
    uint16 constant IS_NOT_OWNER = 102;
    uint16 constant WRONG_PHASE = 103;
    uint16 constant LOW_OPEN_DURATION = 104;
    uint16 constant LOW_MSG_VALUE = 105;
    uint16 constant IS_NOT_SELF = 106;

    // English
    uint16 constant LOW_STEP_VALUE = 201;
    uint16 constant VALUE_LESS_THAN_START_VALUE = 203;
    uint16 constant VALUE_LESS_THAN_STEP_FROM_HIGHEST_VALUE = 204;
    uint16 constant VALUE_MORE_THAN_START_VALUE = 205;
    uint16 constant VALUE_MORE_THAN_STEP_FROM_LOWEST_VALUE = 206;

    // Dutch
    uint16 constant START_LESS_THAN_FINISH = 301;
    uint16 constant START_MORE_THAN_FINISH = 302;
    uint16 constant VALUE_LESS_THAN_CURRENT_PRICE = 303;
    uint16 constant VALUE_MORE_THAN_CURRENT_PRICE = 304;

    // Blind
    uint16 constant LOW_FEE_VALUE = 401;
    uint16 constant LOW_DEPOSIT_VALUE = 402;
    uint16 constant VALUE_LESS_THAN_DEPOSIT = 403;
    uint16 constant IS_NOT_FROM_BID = 404;
    uint16 constant NOT_ENOUGH_TOKENS = 405;
    uint16 constant IS_NOT_AUCTION = 444;

    // Root
    uint16 constant IS_NOT_INITED = 501;
    uint16 constant IS_ALREADY_INITED = 502;
    uint16 constant LOW_DEPLOY_VALUE = 503;
    uint16 constant AUCTIONS_CODES_NOT_INITED = 504;
    uint16 constant IS_NOT_FROM_AUCTION = 505;
}
