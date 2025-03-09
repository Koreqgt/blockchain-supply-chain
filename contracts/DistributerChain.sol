// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DistributorRetailer {
    address public distributor;
    address public retailer;

    struct DistributionInfo {
        string productId;
        uint256 shippingDate;
        bool dispatched;
        bool received;
    }
    mapping(string => DistributionInfo) public distributionInfos;

    event ProductDispatched(string indexed productId, uint256 shippingDate);
    event ProductReceived(string indexed productId, uint256 receivedDate);

    // Constructor: deployer is the distributor; retailer address must be provided
    constructor(address _retailer) {
        distributor = msg.sender;
        retailer = _retailer;
    }

    // Distributor dispatches the product
    function dispatchProduct(string memory _productId, uint256 _shippingDate) public {
        require(msg.sender == distributor, "Only distributor can dispatch product");
        require(!distributionInfos[_productId].dispatched, "Product already dispatched");
        distributionInfos[_productId] = DistributionInfo(_productId, _shippingDate, true, false);
        emit ProductDispatched(_productId, _shippingDate);
    }

    // Retailer confirms receipt of the product
    function confirmReceipt(string memory _productId, uint256 _receivedDate) public {
        require(msg.sender == retailer, "Only retailer can confirm receipt");
        require(distributionInfos[_productId].dispatched, "Product not dispatched");
        require(!distributionInfos[_productId].received, "Product already confirmed as received");
        distributionInfos[_productId].received = true;
        emit ProductReceived(_productId, _receivedDate);
    }
}
