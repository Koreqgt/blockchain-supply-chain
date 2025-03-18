// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SupplyChain {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    enum RoleType {
        Supplier,
        Manufacturer,
        Distributor,
        Retailer
    }

    enum ProductStage {
        RawMaterialSupplied,
        Manufactured,
        Distributed,
        AtRetail,
        Sold
    }

    struct Business {
        uint256 id;
        address wallet;
        string name;
        string businessAddress;
        string phoneNumber;
        string companyRegNumber;
        RoleType role;
    }

    struct Product {
        uint256 id;
        string name;
        string description;
        uint256 supplierId;
        uint256 manufacturerId;
        uint256 distributorId;
        uint256 retailerId;
        ProductStage stage;
    }

    uint256 public businessCount;
    uint256 public productCounter;
    mapping(uint256 => Business) public businesses;
    mapping(address => uint256) public businessMapping;
    mapping(uint256 => Product) public products;

    event BusinessRegistered(
        uint256 indexed id,
        address indexed wallet,
        string name,
        RoleType role
    );

    event ProductRegistered(uint256 indexed id, string name);
    event ProductStatusUpdated(uint256 indexed id, ProductStage newStage);

    function registerBusiness(
        address _wallet,
        string memory _name,
        string memory _businessAddress,
        string memory _phoneNumber,
        string memory _companyRegNumber,
        RoleType _role
    ) public onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");
        require(businessMapping[_wallet] == 0, "Business already registered");

        businessCount++;
        businesses[businessCount] = Business(
            businessCount,
            _wallet,
            _name,
            _businessAddress,
            _phoneNumber,
            _companyRegNumber,
            _role
        );
        businessMapping[_wallet] = businessCount;

        emit BusinessRegistered(businessCount, _wallet, _name, _role);
    }

    function getBusinessByWallet(address _wallet) public view returns (Business memory) {
        uint256 id = businessMapping[_wallet];
        require(id != 0, "Business not registered");
        return businesses[id];
    }

    function registerProduct(string memory name, string memory description) public {
        uint256 businessId = businessMapping[msg.sender];
        require(businessId != 0, "Business not registered.");
        require(businesses[businessId].role == RoleType.Supplier, "Only suppliers can register products.");

        productCounter++;
        products[productCounter] = Product(
            productCounter, name, description, businessId, 0, 0, 0, ProductStage.RawMaterialSupplied
        );

        emit ProductRegistered(productCounter, name);
    }

    function moveToManufacturing(uint256 productId) public {
        uint256 businessId = businessMapping[msg.sender];
        require(businessId != 0, "Business not registered.");
        require(businesses[businessId].role == RoleType.Manufacturer, "Only manufacturers can process.");
        require(products[productId].stage == ProductStage.RawMaterialSupplied, "Incorrect product stage.");

        products[productId].manufacturerId = businessId;
        products[productId].stage = ProductStage.Manufactured;

        emit ProductStatusUpdated(productId, ProductStage.Manufactured);
    }

    function moveToDistribution(uint256 productId) public {
        uint256 businessId = businessMapping[msg.sender];
        require(businessId != 0, "Business not registered.");
        require(businesses[businessId].role == RoleType.Distributor, "Only distributors can process.");
        require(products[productId].stage == ProductStage.Manufactured, "Incorrect product stage.");

        products[productId].distributorId = businessId;
        products[productId].stage = ProductStage.Distributed;

        emit ProductStatusUpdated(productId, ProductStage.Distributed);
    }

    function moveToRetail(uint256 productId) public {
        uint256 businessId = businessMapping[msg.sender];
        require(businessId != 0, "Business not registered.");
        require(businesses[businessId].role == RoleType.Retailer, "Only retailers can process.");
        require(products[productId].stage == ProductStage.Distributed, "Incorrect product stage.");

        products[productId].retailerId = businessId;
        products[productId].stage = ProductStage.AtRetail;

        emit ProductStatusUpdated(productId, ProductStage.AtRetail);
    }

    function markAsSold(uint256 productId) public {
        uint256 businessId = businessMapping[msg.sender];
        require(businessId != 0, "Business not registered.");
        require(businesses[businessId].role == RoleType.Retailer, "Only retailers can sell.");
        require(products[productId].retailerId == businessId, "Retailer mismatch.");
        require(products[productId].stage == ProductStage.AtRetail, "Incorrect product stage.");

        products[productId].stage = ProductStage.Sold;

        emit ProductStatusUpdated(productId, ProductStage.Sold);
    }

    function getProductStatus(uint256 productId) public view returns (string memory) {
        require(productId > 0 && productId <= productCounter, "Invalid product ID.");

        if (products[productId].stage == ProductStage.RawMaterialSupplied) return "Raw Material Supplied";
        if (products[productId].stage == ProductStage.Manufactured) return "Manufactured";
        if (products[productId].stage == ProductStage.Distributed) return "Distributed";
        if (products[productId].stage == ProductStage.AtRetail) return "At Retail";
        if (products[productId].stage == ProductStage.Sold) return "Sold";

        return "Unknown Stage";
    }
}
