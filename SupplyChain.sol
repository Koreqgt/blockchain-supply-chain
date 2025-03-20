// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Custom Errors
error OwnerOnly();
error NotRegistered();
error BadID();
error RoleRestricted();
error InvalidAddress();
error AlreadyRegistered();
error NotListed();
error OrderNotConfirmed();
error NotDispatched();
error NotReceived();
error QCFailOrManufactured();
error NotManufactured();
error QCFailDistributor();
error QCFailRetailer();
error DetailsRequired();

contract SupplyChain {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Modifiers using custom errors.
    modifier onlyOwner() {
        if (msg.sender != owner) revert OwnerOnly();
        _;
    }

    modifier onlyRegistered() {
        if (businessMapping[msg.sender] == 0) revert NotRegistered();
        _;
    }

    modifier validProduct(uint256 _productId) {
        if (_productId == 0 || _productId > productCounter) revert BadID();
        _;
    }

    modifier onlyRole(RoleType _role) {
        uint256 bId = businessMapping[msg.sender];
        if (bId == 0) revert NotRegistered();
        if (businesses[bId].role != _role) revert RoleRestricted();
        _;
    }

    enum RoleType {
        Supplier,
        Manufacturer,
        Distributor,
        Retailer
    }
    
    // Product stages.
    enum ProductStage {
        Listed,                           // 0: Listing created by SupplyChainManager.
        OrderReceivedBySupplier,          // 1: Supplier confirms order received.
        RawMaterialsDispatched,           // 2: Supplier dispatches raw materials.
        RawMaterialsReceivedByManufacturer, // 3: Manufacturer receives raw materials.
        QCInspectionByManufacturer,       // 4: Manufacturer does QC inspection.
        QCApprovedByManufacturer,         // 5: QC approved; waiting manufacture.
        Manufactured,                     // 6: Manufacturing complete.
        DispatchedToDistributor,          // 7: Dispatched to Distributor.
        ReceivedByDistributor,            // 8: Distributor receives.
        QCInspectionByDistributor,        // 9: Distributor does QC.
        QCApprovedByDistributor,          // 10: QC approved by distributor.
        DispatchedToRetailer,             // 11: Dispatched to Retailer.
        ReceivedByRetailer,               // 12: Retailer receives.
        QCInspectionByRetailer,           // 13: Retailer does QC.
        QCApprovedByRetailer,             // 14: QC approved by retailer.
        Sold,                             // 15: Sale completed.
        Returned                          // 16: Rejected/returned.
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

    struct ProductHistory {
        uint256 timestamp;
        ProductStage stage;
        uint256 businessId;
        string details;
    }

    uint256 public businessCount;
    uint256 public productCounter;

    mapping(uint256 => Business) public businesses;   // businessId => Business
    mapping(address => uint256) public businessMapping; // wallet => businessId
    mapping(uint256 => Product) public products;        // productId => Product
    mapping(uint256 => ProductHistory[]) public productHistory; // productId => history records

    event BusinessRegistered(
        uint256 indexed id,
        address indexed wallet,
        string name,
        RoleType role
    );
    event ProductRegistered(uint256 indexed id, string name);
    event ProductStatusUpdated(uint256 indexed id, ProductStage newStage);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ------------------ Owner Functions ------------------
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress();
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function registerBusiness(
        address _wallet,
        string memory _name,
        string memory _businessAddress,
        string memory _phoneNumber,
        string memory _companyRegNumber,
        RoleType _role
    ) public onlyOwner {
        if (_wallet == address(0)) revert InvalidAddress();
        if (businessMapping[_wallet] != 0) revert AlreadyRegistered();
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
        if (id == 0) revert NotRegistered();
        return businesses[id];
    }

    // ------------------ SupplyChainManager Functions ------------------
    function createProductListing(string memory name, string memory description) public onlyOwner {
        productCounter++;
        products[productCounter] = Product(
            productCounter,
            name,
            description,
            0, // supplierId to be set later.
            0,
            0,
            0,
            ProductStage.Listed
        );
        productHistory[productCounter].push(ProductHistory(block.timestamp, ProductStage.Listed, 0, "Listing created"));
        emit ProductRegistered(productCounter, name);
    }

    // ------------------ Supplier Functions ------------------
    function confirmOrderReceivedBySupplier(uint256 productId) public validProduct(productId) onlyRole(RoleType.Supplier) {
        if (products[productId].stage != ProductStage.Listed) revert NotListed();
        uint256 bId = businessMapping[msg.sender];
        products[productId].supplierId = bId;
        products[productId].stage = ProductStage.OrderReceivedBySupplier;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.OrderReceivedBySupplier, bId, "Order rec'd"));
        emit ProductStatusUpdated(productId, ProductStage.OrderReceivedBySupplier);
    }

    function dispatchRawMaterials(uint256 productId, string memory details) public validProduct(productId) onlyRole(RoleType.Supplier) {
        if (products[productId].stage != ProductStage.OrderReceivedBySupplier) revert OrderNotConfirmed();
        uint256 bId = businessMapping[msg.sender];
        products[productId].stage = ProductStage.RawMaterialsDispatched;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.RawMaterialsDispatched, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.RawMaterialsDispatched);
    }

    // ------------------ Manufacturer Functions ------------------
    function manufacturerReceiveRawMaterials(uint256 productId, string memory details) public validProduct(productId) onlyRole(RoleType.Manufacturer) {
        if (products[productId].stage != ProductStage.RawMaterialsDispatched) revert NotDispatched();
        uint256 bId = businessMapping[msg.sender];
        products[productId].manufacturerId = bId;
        products[productId].stage = ProductStage.RawMaterialsReceivedByManufacturer;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.RawMaterialsReceivedByManufacturer, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.RawMaterialsReceivedByManufacturer);
    }

    function qcInspectionByManufacturer(uint256 productId, bool approved, string memory details) public validProduct(productId) onlyRole(RoleType.Manufacturer) {
        if (products[productId].stage != ProductStage.RawMaterialsReceivedByManufacturer) revert NotReceived();
        if (bytes(details).length == 0) revert DetailsRequired();
        uint256 bId = businessMapping[msg.sender];
        if (approved) {
            products[productId].stage = ProductStage.QCApprovedByManufacturer;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.QCApprovedByManufacturer, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.QCApprovedByManufacturer);
        } else {
            products[productId].stage = ProductStage.Returned;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Returned, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.Returned);
        }
    }

    function completeManufacturing(uint256 productId, string memory details) public validProduct(productId) onlyRole(RoleType.Manufacturer) {
        if (products[productId].stage != ProductStage.QCApprovedByManufacturer) revert QCFailOrManufactured();
        uint256 bId = businessMapping[msg.sender];
        products[productId].stage = ProductStage.Manufactured;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Manufactured, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.Manufactured);
    }

    function dispatchToDistributor(uint256 productId, string memory details) public validProduct(productId) onlyRole(RoleType.Manufacturer) {
        if (products[productId].stage != ProductStage.Manufactured) revert NotManufactured();
        uint256 bId = businessMapping[msg.sender];
        products[productId].stage = ProductStage.DispatchedToDistributor;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.DispatchedToDistributor, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.DispatchedToDistributor);
    }

    // ------------------ Distributor Functions ------------------
    function receiveByDistributor(uint256 productId, string memory details) public validProduct(productId) onlyRole(RoleType.Distributor) {
        if (products[productId].stage != ProductStage.DispatchedToDistributor) revert NotDispatched();
        uint256 bId = businessMapping[msg.sender];
        products[productId].distributorId = bId;
        products[productId].stage = ProductStage.ReceivedByDistributor;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.ReceivedByDistributor, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.ReceivedByDistributor);
    }

    function qcInspectionByDistributor(uint256 productId, bool approved, string memory details) public validProduct(productId) onlyRole(RoleType.Distributor) {
        if (products[productId].stage != ProductStage.ReceivedByDistributor) revert NotReceived();
        if (bytes(details).length == 0) revert DetailsRequired();
        uint256 bId = businessMapping[msg.sender];
        if (approved) {
            products[productId].stage = ProductStage.QCApprovedByDistributor;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.QCApprovedByDistributor, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.QCApprovedByDistributor);
        } else {
            products[productId].stage = ProductStage.Returned;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Returned, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.Returned);
        }
    }

    function dispatchByDistributor(uint256 productId, string memory details) public validProduct(productId) onlyRole(RoleType.Distributor) {
        if (products[productId].stage != ProductStage.QCApprovedByDistributor) revert QCFailDistributor();
        uint256 bId = businessMapping[msg.sender];
        products[productId].stage = ProductStage.DispatchedToRetailer;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.DispatchedToRetailer, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.DispatchedToRetailer);
    }

    // ------------------ Retailer Functions ------------------
    function receiveByRetailer(uint256 productId, string memory details) public validProduct(productId) onlyRole(RoleType.Retailer) {
        if (products[productId].stage != ProductStage.DispatchedToRetailer) revert NotDispatched();
        uint256 bId = businessMapping[msg.sender];
        products[productId].retailerId = bId;
        products[productId].stage = ProductStage.ReceivedByRetailer;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.ReceivedByRetailer, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.ReceivedByRetailer);
    }

    function qcInspectionByRetailer(uint256 productId, bool approved, string memory details) public validProduct(productId) onlyRole(RoleType.Retailer) {
        if (products[productId].stage != ProductStage.ReceivedByRetailer) revert NotReceived();
        if (bytes(details).length == 0) revert DetailsRequired();
        uint256 bId = businessMapping[msg.sender];
        if (approved) {
            products[productId].stage = ProductStage.QCApprovedByRetailer;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.QCApprovedByRetailer, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.QCApprovedByRetailer);
        } else {
            products[productId].stage = ProductStage.Returned;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Returned, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.Returned);
        }
    }

    function markAsSold(uint256 productId, string memory details) public validProduct(productId) onlyRole(RoleType.Retailer) {
        if (products[productId].stage != ProductStage.QCApprovedByRetailer) revert QCFailRetailer();
        uint256 bId = businessMapping[msg.sender];
        products[productId].stage = ProductStage.Sold;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Sold, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.Sold);
    }

    // ------------------ Getters ------------------
    function getProductStatus(uint256 productId) public view validProduct(productId) returns (string memory) {
        ProductStage stage = products[productId].stage;
        if (stage == ProductStage.Listed) return "Listed";
        if (stage == ProductStage.OrderReceivedBySupplier) return "Order Received by Supplier";
        if (stage == ProductStage.RawMaterialsDispatched) return "Raw Materials Dispatched";
        if (stage == ProductStage.RawMaterialsReceivedByManufacturer) return "Raw Materials Received by Manufacturer";
        if (stage == ProductStage.QCInspectionByManufacturer) return "Under QC Inspection by Manufacturer";
        if (stage == ProductStage.QCApprovedByManufacturer) return "QC Approved by Manufacturer";
        if (stage == ProductStage.Manufactured) return "Manufactured";
        if (stage == ProductStage.DispatchedToDistributor) return "Dispatched to Distributor";
        if (stage == ProductStage.ReceivedByDistributor) return "Received by Distributor";
        if (stage == ProductStage.QCInspectionByDistributor) return "Under QC Inspection by Distributor";
        if (stage == ProductStage.QCApprovedByDistributor) return "QC Approved by Distributor";
        if (stage == ProductStage.DispatchedToRetailer) return "Dispatched to Retailer";
        if (stage == ProductStage.ReceivedByRetailer) return "Received by Retailer";
        if (stage == ProductStage.QCInspectionByRetailer) return "Under QC Inspection by Retailer";
        if (stage == ProductStage.QCApprovedByRetailer) return "QC Approved by Retailer";
        if (stage == ProductStage.Sold) return "Sold";
        if (stage == ProductStage.Returned) return "Returned/Rejected";
        return "Unknown Stage";
    }

    function getProductDetails(uint256 productId) public view validProduct(productId) returns (Product memory) {
        return products[productId];
    }

    function getProductHistory(uint256 productId) public view validProduct(productId) returns (ProductHistory[] memory) {
        return productHistory[productId];
    }
}
