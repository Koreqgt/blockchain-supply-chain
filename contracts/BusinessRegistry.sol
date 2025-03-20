// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/***************************************
 * BusinessRegistry Contract
 ***************************************/
contract BusinessRegistry {
    address public owner;
    uint256 public businessCount;

    // Define roles; same order as used in ProductManager.
    enum RoleType {
        Supplier,
        Manufacturer,
        Distributor,
        Retailer
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

    // Mapping from business id to Business and from wallet to id.
    mapping(uint256 => Business) public businesses;
    mapping(address => uint256) public businessMapping;

    event BusinessRegistered(
        uint256 indexed id,
        address indexed wallet,
        string name,
        RoleType role
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can register business");
        _;
    }

    /**
     * @dev Registers a new business. Only the owner (SupplyChainManager) can call.
     */
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

    /**
     * @dev Retrieves business details by wallet.
     */
    function getBusinessByWallet(address _wallet) public view returns (Business memory) {
        uint256 id = businessMapping[_wallet];
        require(id != 0, "Business not registered");
        return businesses[id];
    }

    /**
     * @dev Returns the business id for a wallet.
     */
    function getBusinessId(address _wallet) public view returns (uint256) {
        return businessMapping[_wallet];
    }

    /**
     * @dev Returns the role (as uint8) of the business associated with _wallet.
     */
    function getBusinessRole(address _wallet) public view returns (uint8) {
        uint256 id = businessMapping[_wallet];
        require(id != 0, "Business not registered");
        return uint8(businesses[id].role);
    }
}
