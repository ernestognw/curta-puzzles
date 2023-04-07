// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Base.sol";

contract Forked is CommonBase {
    uint256 public mainnetFork;
    string public MAINNET_RPC_URL = "https://mainnet.infura.io/v3/<<API_KEY>>";

    modifier inMainnet() {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        _;
    }
}
