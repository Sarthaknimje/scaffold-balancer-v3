// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IMockYieldProtocol } from "./Interfaces/IMockYieldProtocol.sol";

contract MockYieldProtocol is IMockYieldProtocol {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    uint256 public yieldRate;

    constructor(address _token, uint256 _initialYieldRate) {
        token = IERC20(_token);
        yieldRate = _initialYieldRate;
    }

    function setYieldRate(uint256 _newYieldRate) external {
        yieldRate = _newYieldRate;
    }

    function currentYield(uint256 amount) external view override returns (uint256) {
        return (amount * yieldRate) / 1e18;
    }

    function potentialYield(uint256 amount) external view override returns (uint256) {
        return (amount * yieldRate) / 1e18;
    }

    function withdraw(uint256 amount) external override {
        token.safeTransfer(msg.sender, amount);
    }

    function deposit(uint256 amount) external {
        token.safeTransferFrom(msg.sender, address(this), amount);
    }
}
