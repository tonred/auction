pragma ton-solidity >= 0.39.0;

import "./Lib.sol";


contract BlindBid {
    uint8 constant SEND_ALL_GAS_AND_DELETE = 160;


    address static _auction;
    address static _owner;
    uint256 static _hash;


    modifier onlyAuction() {
        require(msg.sender == _auction, Errors.IS_NOT_AUCTION);
        _;
    }


    constructor() public onlyAuction {
        tvm.accept();
    }


    function remove() onlyAuction responsible public view returns (address, uint256) {
        tvm.accept();
        return {value : 0, flag : SEND_ALL_GAS_AND_DELETE, bounce: false}(_owner, _hash);
    }

    function confirm(
        uint128 value,
        uint128 msgValue,
        address wallet
    ) onlyAuction responsible public view returns (address, uint256, uint128, uint128, address) {
        tvm.accept();
        return {value: 0, flag: SEND_ALL_GAS_AND_DELETE, bounce: false}(_owner, _hash, value, msgValue, wallet);
    }

}
