// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IYieldOptimizerFactory } from "./Interfaces/IYieldOptimizerFactory.sol";
import { YieldOptimizer } from "./YieldOptimizer.sol";

contract YieldOptimizerFactory is IYieldOptimizerFactory, Ownable, ReentrancyGuard {
    mapping(address => address) public poolToOptimizer;

    constructor() Ownable(msg.sender) {}

    function createOptimizer(address pool) external onlyOwner returns (address) {
        require(poolToOptimizer[pool] == address(0), "Optimizer already exists");

        YieldOptimizer optimizer = new YieldOptimizer(pool, msg.sender, address(this));
        poolToOptimizer[pool] = address(optimizer);

        emit OptimizerCreated(pool, address(optimizer));
        return address(optimizer);
    }

    function getOptimizer(address pool) external view override returns (address) {
        return poolToOptimizer[pool];
    }

    function removeOptimizer(address pool) external onlyOwner {
        require(poolToOptimizer[pool] != address(0), "Optimizer does not exist");
        delete poolToOptimizer[pool];
        emit OptimizerRemoved(pool);
    }
}
