// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplierManufacturer {
    address public supplier;
    address public manufacturer;

    struct RawMaterial {
        string rfid;               // Unique identification (RFID/QR Code)
        string batchNumber;
        string qualityInspectionData;
        bool exists;
        bool accepted;             // Whether the manufacturer accepted the raw material
    }
    mapping(string => RawMaterial) public rawMaterials;

    event RawMaterialRegistered(string indexed rfid, string batchNumber, address supplier);
    event RawMaterialAccepted(string indexed rfid, address manufacturer);

    // Constructor: deployer is the supplier; manufacturer address must be provided
    constructor(address _manufacturer) {
        supplier = msg.sender;
        manufacturer = _manufacturer;
    }

    // Supplier registers raw material details
    function registerRawMaterial(
        string memory _rfid,
        string memory _batchNumber,
        string memory _qualityInspectionData
    ) public {
        require(msg.sender == supplier, "Only supplier can register raw materials");
        require(!rawMaterials[_rfid].exists, "Raw material already registered");
        rawMaterials[_rfid] = RawMaterial(_rfid, _batchNumber, _qualityInspectionData, true, false);
        emit RawMaterialRegistered(_rfid, _batchNumber, supplier);
    }

    // Manufacturer accepts the raw material
    function acceptRawMaterial(string memory _rfid) public {
        require(msg.sender == manufacturer, "Only manufacturer can accept raw materials");
        require(rawMaterials[_rfid].exists, "Raw material not found");
        require(!rawMaterials[_rfid].accepted, "Raw material already accepted");
        rawMaterials[_rfid].accepted = true;
        emit RawMaterialAccepted(_rfid, manufacturer);
    }
}
