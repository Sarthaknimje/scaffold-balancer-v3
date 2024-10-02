// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

interface IMockYieldProtocol {
    function currentYield(uint256 amount) external view returns (uint256);
    function potentialYield(uint256 amount) external view returns (uint256);
    function withdraw(uint256 amount) external;
}
