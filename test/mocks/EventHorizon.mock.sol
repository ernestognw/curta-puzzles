// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

import "~/EventHorizon.sol";

contract EventHorizonMock is EventHorizon {
    function gammaFn(uint256 _xyz, uint256 gas) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_xyz, gas)));
    }

    function generate(address _seed, uint256 gas) external pure returns (uint256) {
        return gammaFn(uint256(uint160(_seed)), gas) | PLANK_CONSTANT;
    }
}
