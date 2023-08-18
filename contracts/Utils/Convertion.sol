// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";

library Convertion {
    struct Integer {
        uint value;
        bool neg;
    }

    function bigInt2Integer(CommonTypes.BigInt memory num) internal pure returns (Integer memory result) {
        result.neg = num.neg;
        require(num.val.length <= 32, "Length exceeds");
        if (num.val.length == 0) result.value = 0;
        else result.value = uint(bytes32(num.val)) >> (8 * (32 - num.val.length));
    }

    function bigInt2Uint(CommonTypes.BigInt memory num) internal pure returns (uint) {
        Integer memory r = bigInt2Integer(num);
        require(!r.neg, "Input is negative");
        return r.value;
    }

    function uint2BigInt(uint num) internal pure returns (CommonTypes.BigInt memory) {
        return CommonTypes.BigInt({
            val: abi.encodePacked(num),
            neg: false
        });
    }
}
