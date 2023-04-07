// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./mocks/EventHorizon.mock.sol";
import "./utils/Forked.sol";

interface ICurta {
    function solve(uint32 _puzzleId, uint256 _solution) external;
}

contract EventHorizonTest is Forked, Test {
    ICurta public curta;
    EventHorizonMock public puzzle;

    address me = address(0);
    address _curta = 0x0000000006bC8D9e5e9d436217B88De704a9F307;

    function setUp() public {
        curta = ICurta(_curta);
        puzzle = new EventHorizonMock();
    }

    /**
     * @dev Naive attempt at solving in mainnet by brute force
     */
    function test_mainnet() public inMainnet {
        uint256 gas = 377653;
        for (uint256 solution = 0xffff; solution >= 0xff; solution--) {
            (, bytes memory result) = address(curta).call{gas: gas}(
                abi.encodeCall(ICurta.solve, (6, solution))
            );
            if (bytes32(result) != 0x0) {
                console.log(gas, solution);
                assertTrue(false); // Fail on purpose and show the result
            }
        }
    }

    /**
     * @dev Same as before but fuzzing
     */
    function test_verify(uint256 solution, uint256 gas) public inMainnet {
        solution = bound(solution, 0, 0xfffff);
        gas = bound(gas, 97000, 500_000);

        vm.startPrank(me);

        (bool success, bytes memory result) = address(puzzle).call{gas: gas}(
            abi.encodeCall(ICurta.solve, (6, solution))
        );
        vm.expectRevert();
        require(success);
        console.log(uint256(bytes32(result)));
        console.log(gas);
        console.log(solution);
        assertTrue(uint256(bytes32(result)) == 0);

        vm.stopPrank();
    }

    /**
     * @dev Change the loop boundries to try chunks.
     * Most of the cases generate a 4-nibble solution. The best is to get a 3-nibble one.
     */
    function test_generate() public view {
        uint256 minor = type(uint32).max;
        uint256 minorGas;
        for (uint256 gas = 4_000_000; gas > 3_000_000; gas--) {
            uint256 generated = puzzle.generate(me, gas);
            uint256 current = generated & type(uint32).max;
            if (current < minor) {
                minor = current;
                minorGas = gas;
            }
        }
        console.log("===");
        console.logBytes32(bytes32(minor));
        console.log(minorGas);
    }

    /**
     * @dev I used this when my simulations ended up returning a different generated to what I thought
     * Replace target with the value you're looking for and you'll get the gas offset until the generate()
     * gasleft()
     */
    function test_getTargetGenerate() public view {
        address input = me;
        uint256 target = 40147052241097065511998149379894146345822047184621477665823801257202838864799;

        for (uint256 gas = 3820164; gas > 3_000_000; gas--) {
            uint256 generated = puzzle.generate(input, gas);
            if (generated == target) console.log(gas);
        }
    }

    /**
     * @dev I used this when my simulations ended up returing a different gamma to what I thought
     * Replace target with the value you're looking for and you'll get the gasleft() required to generate
     * the target you set.
     */
    function test_getTargetGamma() public view {
        uint256 input = 0x3ce8;
        uint256 target = 33467985753325789985550456184030083598105212210127866907771380096164759278391;

        for (uint256 gas = 3731492; gas > 3_000_000; gas--) {
            uint256 gamma = puzzle.gammaFn(input, gas);
            if (gamma == target) console.log(gas);
        }
    }

    /**
     * @dev An attempt of fuzzing the semi-predictable gammas in the loop.
     * It doesn't work, and it's kept for showing purposes
     */
    function test_gamma() public view {
        uint256 startingGas = 3819212;
        uint256 gasZero = 330;
        uint256[] memory gasMap = new uint256[](0xf + 1);

        for (uint256 i; i <= 0xf; i++) {
            for (uint256 j; j <= 5 * 16; j++) {
                gasMap[0] = gasZero;
                gasMap[1] = gasMap[0] + 48 + (((j + 0) % (5))); // 1
                gasMap[2] = gasMap[1] + 48 + (((j + 1) % (5))); // 2
                gasMap[3] = gasMap[2] + 48 + (((j + 2) % (5))); // 3
                gasMap[4] = gasMap[3] + 48 + (((j + 3) % (5))); // 4
                gasMap[5] = gasMap[4] + 48 + (((j + 4) % (5))); // 5
                gasMap[6] = gasMap[5] + 48 + (((j + 5) % (5))); // 6
                gasMap[7] = gasMap[6] + 48 + (((j + 6) % (5))); // 7
                gasMap[8] = gasMap[7] + 48 + (((j + 7) % (5))); // 8
                gasMap[9] = gasMap[8] + 48 + (((j + 8) % (5))); // 9
                gasMap[10] = gasMap[9] + 48 + (((j + 9) % (5))); // a
                gasMap[11] = gasMap[10] + 48 + (((j + 10) % (5))); // b
                gasMap[12] = gasMap[11] + 48 + (((j + 11) % (5))); // c
                gasMap[13] = gasMap[12] + 48 + (((j + 12) % (5))); // d
                gasMap[14] = gasMap[13] + 48 + (((j + 13) % (5))); // e
                gasMap[15] = gasMap[14] + 48 + (((j + 14) % (5))); // f

                for (uint256 solution = 0xffff; solution > 0; solution--) {
                    uint256 gas = startingGas;
                    uint256 remove;
                    uint256 gamma1 = puzzle.gammaFn(solution, startingGas);

                    remove = gasMap[gamma1 & (0xF >> 0)];
                    if (gas < remove) continue; // Overflow
                    gas -= remove;
                    uint256 gamma2 = puzzle.gammaFn(solution, gas);

                    remove = gasMap[gamma2 & (0xF0 >> 4)];
                    if (gas < remove) continue; // Overflow
                    gas -= remove;
                    uint256 gamma3 = puzzle.gammaFn(solution, gas);

                    if (
                        (gamma1 & 0xf == 0x5) &&
                        (gamma2 & 0xf0 == 0x10) &&
                        (gamma3 & 0xf00 == 0xd00)
                    ) {
                        console.logBytes32(bytes2(uint16(solution)));
                        // console.log(gamma1);
                        // console.log(gamma2);
                        // console.log(gamma3);
                        // console.log(gamma4);
                        console.log("==");
                    }
                }
            }
        }
    }
}
