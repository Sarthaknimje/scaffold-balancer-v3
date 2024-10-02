// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

interface IYieldOptimizer {
    event YieldOptimized(address indexed pool, uint256 timestamp);

    function calculateYields() external view returns (uint256 currentYield, uint256 potentialYield);
    function optimizeYield() external;
    function withdrawFunds(address token, uint256 amount) external;
}
