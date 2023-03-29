// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./mocks/WhatAreBuckets.mock.sol";

contract WhatAreBucketsTest is Test {
    WhatAreBucketsMock public puzzle;

    enum Ops {
        EMPTY_1,
        FILL_1,
        EMPTY_2,
        FILL_2,
        POUR_1_2,
        NOOP,
        POUR_2_1
        // 7 is not used
    }

    function setUp() public {
        puzzle = new WhatAreBucketsMock();
    }

    function test_verify() public {
        address player = 0xc7E42375A7B463788654d4C88c073C12223dcaC2;
        uint256 _start = puzzle.generate(player);
        assertTrue(
            puzzle.verify(
                _start,
                _solve(player) ^ uint256(keccak256(abi.encodePacked(_start)))
            )
        );
    }

    // Inspired by https://hackmd.io/@xNSnimr_Rk68TArjAjMQvw/HkypUNJW2
    function _solve(address player) private view returns (uint256) {
        // generate() gives the following:
        // | Capacity 1 | Capacity 2 | Volume 1 | Volume 2 |
        // | c1         | c2         | p1       | p2       |
        //
        // The objective is to get:
        // | Capacity 1 | Capacity 2 | Volume 1 | Volume 2 |
        // | c1         | c2         | 0        | 1        |

        // Generate a seed for an address
        uint256 originalState = puzzle.generate(player);
        // Copy so it can be XOR'd to mask the solution
        uint256 state = originalState;

        // Get the capacity of bucket 2
        uint256 c2 = ((state >> 16) & 0xff);

        // Variables
        uint256 commands;
        bool p2Full;
        uint8 count;

        // 256 / 3. Actually 85.333...
        uint8 MAX_COMMANDS = 85;

        // Algorith proposed in the article referenced
        while (count <= MAX_COMMANDS) {
            // The state is already the solution
            if (state & 0xffff == 1) {
                (commands, state, count) = _exec(
                    commands,
                    state,
                    count,
                    Ops.NOOP
                );
                continue; // Just fill with noops until the end
            }

            (commands, state, count) = _exec(
                commands,
                state,
                count,
                Ops.FILL_1
            );

            do {
                (commands, state, count) = _exec(
                    commands,
                    state,
                    count,
                    Ops.POUR_1_2
                );

                p2Full = state & 0xff == c2;
                if (p2Full) {
                    (commands, state, count) = _exec(
                        commands,
                        state,
                        count,
                        Ops.EMPTY_2
                    );
                }
            } while (p2Full);
        }

        return commands;
    }

    function _exec(
        uint256 commands,
        uint256 state,
        uint8 count,
        Ops op
    ) private view returns (uint256 _commands, uint256 _state, uint8 _count) {
        commands ^= (uint256(op) << (count * 3)); // Add to commands list
        return (commands, puzzle._work(state, uint8(op)), count + 1);
    }
}
