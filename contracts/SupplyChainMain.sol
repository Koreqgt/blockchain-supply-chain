// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BusinessRegistry.sol";
import "./ProductManager.sol";

/***************************************
 * SupplyChainMain Contract
 ***************************************/
contract SupplyChainMain {
    BusinessRegistry public businessRegistry;
    ProductManager public productManager;
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _businessRegistry, address _productManager) {
        owner = msg.sender;
        businessRegistry = BusinessRegistry(_businessRegistry);
        productManager = ProductManager(_productManager);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
