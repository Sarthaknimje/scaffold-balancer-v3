// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

interface IYieldOptimizerFactory {
    event OptimizerCreated(address indexed pool, address optimizer);
    event OptimizerRemoved(address indexed pool);

    function createOptimizer(address pool) external returns (address);
    function getOptimizer(address pool) external view returns (address);
    function removeOptimizer(address pool) external;
}
