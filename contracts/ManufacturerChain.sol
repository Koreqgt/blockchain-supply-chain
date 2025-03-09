// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ManufacturerDistributor {
    address public manufacturer;
    address public distributor;

    struct ManufacturingDetails {
        string productId;
        string rawMaterialRFID;        // Reference to the raw material used
        string machineLogs;
        string manufacturingLineAuth;
        string finalInspectionReports;
        string offChainDataReference;  // Reference for off-chain data
        bool exists;
    }
    mapping(string => ManufacturingDetails) public manufacturingRecords;

    struct Distribution {
        string productId;
        uint256 weight;
        uint256 measurements;          // Example: dimensions or volume
        string packingConditions;
        uint256 anticipatedDeliveryDate; // Unix timestamp
        string gpsData;                // Latest GPS location information
        bool exists;
    }
    mapping(string => Distribution) public distributions;

    event ManufacturingRecorded(string indexed productId, string rawMaterialRFID);
    event DistributionRecorded(string indexed productId, uint256 anticipatedDeliveryDate);
    event GPSDataUpdated(string indexed productId, string newGPSData);

    // Constructor: deployer is the manufacturer; distributor address must be provided
    constructor(address _distributor) {
        manufacturer = msg.sender;
        distributor = _distributor;
    }

    // Manufacturer records product manufacturing details
    function recordManufacturing(
        string memory _productId,
        string memory _rawMaterialRFID,
        string memory _machineLogs,
        string memory _manufacturingLineAuth,
        string memory _finalInspectionReports,
        string memory _offChainDataReference
    ) public {
        require(msg.sender == manufacturer, "Only manufacturer can record manufacturing details");
        require(!manufacturingRecords[_productId].exists, "Manufacturing details already recorded");
        manufacturingRecords[_productId] = ManufacturingDetails(
            _productId,
            _rawMaterialRFID,
            _machineLogs,
            _manufacturingLineAuth,
            _finalInspectionReports,
            _offChainDataReference,
            true
        );
        emit ManufacturingRecorded(_productId, _rawMaterialRFID);
    }

    // Manufacturer records distribution details for the product
    function recordDistribution(
        string memory _productId,
        uint256 _weight,
        uint256 _measurements,
        string memory _packingConditions,
        uint256 _anticipatedDeliveryDate,
        string memory _gpsData
    ) public {
        require(msg.sender == manufacturer, "Only manufacturer can record distribution details");
        require(manufacturingRecords[_productId].exists, "Manufacturing details must be recorded first");
        require(!distributions[_productId].exists, "Distribution already recorded for this product");
        distributions[_productId] = Distribution(
            _productId,
            _weight,
            _measurements,
            _packingConditions,
            _anticipatedDeliveryDate,
            _gpsData,
            true
        );
        emit DistributionRecorded(_productId, _anticipatedDeliveryDate);
    }

    // Distributor updates the GPS data during transit
    function updateGPSData(string memory _productId, string memory _gpsData) public {
        require(msg.sender == distributor, "Only distributor can update GPS data");
        require(distributions[_productId].exists, "Distribution record does not exist");
        distributions[_productId].gpsData = _gpsData;
        emit GPSDataUpdated(_productId, _gpsData);
    }
}
