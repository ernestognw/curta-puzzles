// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

import "~/WhatAreBuckets.sol";

contract WhatAreBucketsMock is WhatAreBuckets {
    function _work(uint256 state, uint8 op) external pure returns (uint256) {
        return super.work(state, op);
    }
}
