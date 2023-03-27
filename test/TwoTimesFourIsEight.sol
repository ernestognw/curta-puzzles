// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "~/TwoTimesFourIsEight.sol";

contract TwoTimesFourIsEightTest is Test {
    TwoTimesFourIsEight public puzzle;

    function setUp() public {
        puzzle = new TwoTimesFourIsEight();
    }

    function test_solution(uint256 solution) public {
        assertEq(
            puzzle.verify(
                1356974779918119916025744992480911349312644144646868926418077318319425191936,
                solution
            ),
            false
        );
    }
}
