// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/***************************************
 * ProductManager Contract
 ***************************************/

// Define an interface so that ProductManager can call functions on BusinessRegistry.
interface IBusinessRegistry {
    function getBusinessId(address _wallet) external view returns (uint256);
    function getBusinessRole(address _wallet) external view returns (uint8);
}

contract ProductManager {
    address public owner;
    IBusinessRegistry public businessRegistry;
    uint256 public productCounter;

    // The product stages – note that the enum values must correspond to the roles defined in BusinessRegistry.
    enum ProductStage {
        Listed,                           // 0: Listing created by SupplyChainManager.
        OrderReceivedBySupplier,          // 1: Supplier confirms order received.
        RawMaterialsDispatched,           // 2: Supplier dispatches raw materials.
        RawMaterialsReceivedByManufacturer, // 3: Manufacturer receives raw materials.
        QCInspectionByManufacturer,       // 4: Manufacturer performs QC inspection.
        QCApprovedByManufacturer,         // 5: QC approved; waiting manufacturing completion.
        Manufactured,                     // 6: Manufacturing complete.
        DispatchedToDistributor,          // 7: Manufacturer dispatches to distributor.
        ReceivedByDistributor,            // 8: Distributor receives product.
        QCInspectionByDistributor,        // 9: Distributor performs QC inspection.
        QCApprovedByDistributor,          // 10: QC approved by distributor.
        DispatchedToRetailer,             // 11: Distributor dispatches to retailer.
        ReceivedByRetailer,               // 12: Retailer receives product.
        QCInspectionByRetailer,           // 13: Retailer performs QC inspection.
        QCApprovedByRetailer,             // 14: QC approved by retailer.
        Sold,                             // 15: Sale completed.
        Returned                          // 16: Rejected/returned at any QC step.
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

    mapping(uint256 => Product) public products;
    mapping(uint256 => ProductHistory[]) public productHistory;

    event ProductRegistered(uint256 indexed id, string name);
    event ProductStatusUpdated(uint256 indexed id, ProductStage newStage);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier validProduct(uint256 _productId) {
        require(_productId > 0 && _productId <= productCounter, "Invalid product ID");
        _;
    }

    // Modifier to check that the caller has the required role.
    // Role numbers: Supplier=0, Manufacturer=1, Distributor=2, Retailer=3.
    modifier onlyRole(uint8 requiredRole) {
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        require(bId != 0, "Not a registered business");
        uint8 role = businessRegistry.getBusinessRole(msg.sender);
        require(role == requiredRole, "Action restricted to specific role");
        _;
    }

    constructor(address _businessRegistry) {
        owner = msg.sender;
        businessRegistry = IBusinessRegistry(_businessRegistry);
    }

    // ------------------ SupplyChainManager Functions ------------------
    // Only the owner (SupplyChainManager) can create a product listing.
    function createProductListing(string memory name, string memory description) public onlyOwner {
        productCounter++;
        products[productCounter] = Product(
            productCounter,
            name,
            description,
            0,
            0,
            0,
            0,
            ProductStage.Listed
        );
        // We use 0 as the businessId for the listing (owner may not be registered).
        productHistory[productCounter].push(ProductHistory(block.timestamp, ProductStage.Listed, 0, "Listing created by SupplyChainManager"));
        emit ProductRegistered(productCounter, name);
    }

    // ------------------ Supplier Functions (role 0) ------------------
    function confirmOrderReceivedBySupplier(uint256 productId) public validProduct(productId) onlyRole(0) {
        require(products[productId].stage == ProductStage.Listed, "Product not in Listed stage");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        products[productId].supplierId = bId;
        products[productId].stage = ProductStage.OrderReceivedBySupplier;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.OrderReceivedBySupplier, bId, "Supplier confirmed order received"));
        emit ProductStatusUpdated(productId, ProductStage.OrderReceivedBySupplier);
    }

    function dispatchRawMaterials(uint256 productId, string memory details) public validProduct(productId) onlyRole(0) {
        require(products[productId].stage == ProductStage.OrderReceivedBySupplier, "Order not confirmed by supplier");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        products[productId].stage = ProductStage.RawMaterialsDispatched;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.RawMaterialsDispatched, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.RawMaterialsDispatched);
    }

    // ------------------ Manufacturer Functions (role 1) ------------------
    function manufacturerReceiveRawMaterials(uint256 productId, string memory details) public validProduct(productId) onlyRole(1) {
        require(products[productId].stage == ProductStage.RawMaterialsDispatched, "Raw materials not dispatched");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        products[productId].manufacturerId = bId;
        products[productId].stage = ProductStage.RawMaterialsReceivedByManufacturer;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.RawMaterialsReceivedByManufacturer, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.RawMaterialsReceivedByManufacturer);
    }

    function qcInspectionByManufacturer(uint256 productId, bool approved, string memory details) public validProduct(productId) onlyRole(1) {
        require(products[productId].stage == ProductStage.RawMaterialsReceivedByManufacturer, "Raw materials not received");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        if (approved) {
            products[productId].stage = ProductStage.QCApprovedByManufacturer;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.QCApprovedByManufacturer, bId, "QC approved by manufacturer"));
            emit ProductStatusUpdated(productId, ProductStage.QCApprovedByManufacturer);
        } else {
            products[productId].stage = ProductStage.Returned;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Returned, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.Returned);
        }
    }

    function completeManufacturing(uint256 productId, string memory details) public validProduct(productId) onlyRole(1) {
        require(products[productId].stage == ProductStage.QCApprovedByManufacturer, "QC not approved or manufacturing complete");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        products[productId].stage = ProductStage.Manufactured;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Manufactured, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.Manufactured);
    }

    function dispatchToDistributor(uint256 productId, string memory details) public validProduct(productId) onlyRole(1) {
        require(products[productId].stage == ProductStage.Manufactured, "Product not manufactured");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        products[productId].stage = ProductStage.DispatchedToDistributor;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.DispatchedToDistributor, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.DispatchedToDistributor);
    }

    // ------------------ Distributor Functions (role 2) ------------------
    function receiveByDistributor(uint256 productId, string memory details) public validProduct(productId) onlyRole(2) {
        require(products[productId].stage == ProductStage.DispatchedToDistributor, "Product not dispatched");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        products[productId].distributorId = bId;
        products[productId].stage = ProductStage.ReceivedByDistributor;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.ReceivedByDistributor, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.ReceivedByDistributor);
    }

    function qcInspectionByDistributor(uint256 productId, bool approved, string memory details) public validProduct(productId) onlyRole(2) {
        require(products[productId].stage == ProductStage.ReceivedByDistributor, "Product not received");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        if (approved) {
            products[productId].stage = ProductStage.QCApprovedByDistributor;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.QCApprovedByDistributor, bId, "QC approved by distributor"));
            emit ProductStatusUpdated(productId, ProductStage.QCApprovedByDistributor);
        } else {
            products[productId].stage = ProductStage.Returned;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Returned, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.Returned);
        }
    }

    function dispatchByDistributor(uint256 productId, string memory details) public validProduct(productId) onlyRole(2) {
        require(products[productId].stage == ProductStage.QCApprovedByDistributor, "QC not approved by distributor");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        products[productId].stage = ProductStage.DispatchedToRetailer;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.DispatchedToRetailer, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.DispatchedToRetailer);
    }

    // ------------------ Retailer Functions (role 3) ------------------
    function receiveByRetailer(uint256 productId, string memory details) public validProduct(productId) onlyRole(3) {
        require(products[productId].stage == ProductStage.DispatchedToRetailer, "Product not dispatched to retailer");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        products[productId].retailerId = bId;
        products[productId].stage = ProductStage.ReceivedByRetailer;
        productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.ReceivedByRetailer, bId, details));
        emit ProductStatusUpdated(productId, ProductStage.ReceivedByRetailer);
    }

    function qcInspectionByRetailer(uint256 productId, bool approved, string memory details) public validProduct(productId) onlyRole(3) {
        require(products[productId].stage == ProductStage.ReceivedByRetailer, "Product not received by retailer");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
        if (approved) {
            products[productId].stage = ProductStage.QCApprovedByRetailer;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.QCApprovedByRetailer, bId, "QC approved by retailer"));
            emit ProductStatusUpdated(productId, ProductStage.QCApprovedByRetailer);
        } else {
            products[productId].stage = ProductStage.Returned;
            productHistory[productId].push(ProductHistory(block.timestamp, ProductStage.Returned, bId, details));
            emit ProductStatusUpdated(productId, ProductStage.Returned);
        }
    }

    function markAsSold(uint256 productId, string memory details) public validProduct(productId) onlyRole(3) {
        require(products[productId].stage == ProductStage.QCApprovedByRetailer, "QC not approved by retailer or already sold");
        uint256 bId = businessRegistry.getBusinessId(msg.sender);
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
        if (stage == ProductStage.Returned) return "Returned";
        return "Unknown Stage";
    }

    function getProductDetails(uint256 productId) public view validProduct(productId) returns (Product memory) {
        return products[productId];
    }

    function getProductHistory(uint256 productId) public view validProduct(productId) returns (ProductHistory[] memory) {
        return productHistory[productId];
    }
}
