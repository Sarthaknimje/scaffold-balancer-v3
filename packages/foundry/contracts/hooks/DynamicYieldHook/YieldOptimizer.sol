// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IYieldOptimizer } from "./Interfaces/IYieldOptimizer.sol";
import { IPoolInfo } from "@balancer-labs/v3-interfaces/contracts/pool-utils/IPoolInfo.sol";
import { IMockYieldProtocol } from "./Interfaces/IMockYieldProtocol.sol";

contract YieldOptimizer is IYieldOptimizer, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public pool;
    address public yieldOptimizerFactory;
    
    IMockYieldProtocol[] public yieldProtocols;
    mapping(address => uint256) public protocolAllocations;

    uint256 private constant ALLOCATION_PRECISION = 10000; // 100.00%

    constructor(address _pool, address _owner, address _factory) Ownable(_owner) {
        pool = _pool;
        yieldOptimizerFactory = _factory;
    }

    function addYieldProtocol(address protocol) external onlyOwner {
        yieldProtocols.push(IMockYieldProtocol(protocol));
    }

    function removeYieldProtocol(uint256 index) external onlyOwner {
        require(index < yieldProtocols.length, "Invalid index");
        yieldProtocols[index] = yieldProtocols[yieldProtocols.length - 1];
        yieldProtocols.pop();
    }

    function calculateYields() external view override returns (uint256 currentYield, uint256 potentialYield) {
        uint256 totalFunds = IERC20(pool).balanceOf(address(this));
        
        for (uint256 i = 0; i < yieldProtocols.length; i++) {
            IMockYieldProtocol protocol = yieldProtocols[i];
            uint256 allocation = protocolAllocations[address(protocol)];
            uint256 protocolFunds = (totalFunds * allocation) / ALLOCATION_PRECISION;
            
            currentYield += protocol.currentYield(protocolFunds);
            potentialYield += protocol.potentialYield(protocolFunds);
        }
    }

    function optimizeYield() external override nonReentrant {
        require(msg.sender == yieldOptimizerFactory, "Unauthorized");

        uint256 totalFunds = IERC20(pool).balanceOf(address(this));
        uint256[] memory yields = new uint256[](yieldProtocols.length);
        uint256 totalYield;

        // Calculate yields
        for (uint256 i = 0; i < yieldProtocols.length; i++) {
            yields[i] = yieldProtocols[i].potentialYield(totalFunds);
            totalYield += yields[i];
        }

        // Reallocate funds based on yields
        for (uint256 i = 0; i < yieldProtocols.length; i++) {
            uint256 newAllocation = (yields[i] * ALLOCATION_PRECISION) / totalYield;
            uint256 targetAmount = (totalFunds * newAllocation) / ALLOCATION_PRECISION;
            uint256 currentAmount = IERC20(pool).balanceOf(address(yieldProtocols[i]));

            if (targetAmount > currentAmount) {
                IERC20(pool).safeTransfer(address(yieldProtocols[i]), targetAmount - currentAmount);
            } else if (targetAmount < currentAmount) {
                yieldProtocols[i].withdraw(currentAmount - targetAmount);
            }

            protocolAllocations[address(yieldProtocols[i])] = newAllocation;
        }

        emit YieldOptimized(pool, block.timestamp);
    }

    function withdrawFunds(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner(), amount);
    }
}
 