// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "~/WhatAreBuckets.sol";

contract WhatAreBucketsTest is Test {
    WhatAreBuckets public puzzle;

    function setUp() public {
        puzzle = new WhatAreBuckets();
    }

    function test_verify(uint256 solution) public {
        assertFalse(
            puzzle.verify(
                0x000000000000000000000000000000000000000000000000000000001d0d1000,
                solution
            )
        );
    }
}
