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

library Errors {
    uint16 constant IS_NOT_ROOT = 101;
}