pragma solidity >=0.4.22 <0.6.0;

import './SafeMath.sol';

interface ERC20Interface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

/** Swap Functionality */
interface ScdMcdMigration {
    function swapEthToSai(uint daiAmt) external;
}
contract Helpers{
    
    /**
     * @dev get uniswap DAI exchange
    */
    function getUniswapDAIExchange() public pure returns (address ude) {
        // ude = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
        // Proxy Address
    }
    
    function getSaiAddress() public pure returns (address saiAddr) {
        // troller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    }

    /**
     * @dev get Eth address
     */
    function getEthAddress() public pure returns (address daiAddr) {
        // troller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    }

}

contract MigrationProxyActions is Helpers{

    function swapEthToSai(
        address userAddress,    // Migration contract address
        uint wad                            // Amount to swap
    ) internal
    {
        ERC20Interface sai = ERC20Interface(getSaiAddress());
        ERC20Interface eth = ERC20Interface(getEthAddress());
        if (eth.allowance(address(this), userAddress) < wad) {
            sai.approve(userAddress, wad);
        ScdMcdMigration(userAddress).swapEthToSai(wad);
    }
    }

}

contract FarmEasy {
    
    using SafeMath for uint256;
    
    /** @dev Product Details
     * @param index ID of the Product
     * @param owner address of the farmer
     * @parma category Classify as Crop, Livestock and Poultry
     * @param name different products of crop/livestock/Poultry
     * @param quantity Amount of product
     */
   struct Product {
       bool active;
       address owner;
       string category;
       string name;
       uint256 quantity;
       uint256 index;
       uint256 sellingPrice;       //per piece
    }
    
    /** @dev Farmer's Registration on platform
     * @param farmer Eth Address of farmer
     * @param farmAddress Name, Location, Country 
     * @param registeredProductsKeys Id of the registered products.
     * @param soldProductsKeys Id of the Sell order records.
     * @param registeredProducts Products registed by the farmer.
     * @notice Products between RegisteredFarmers are added and removed from the registeredProducts array
    @notice Famer address are generated when a farmer registers for the services
     */
    struct Farmer {
        bool active;
        address farmer;
        string farmAddress;
        uint256[] registeredProductsKeys;
        uint256[] soldProductsKeys;
        mapping(uint256 => Product) registeredProducts;
    }
    
    struct Buyer{
        bool active;
        address buyer;
        uint256[] boughtProductsKeys;
        mapping (uint256 => Product) boughtProducts;
    }
    
    /**
     * Events
     */
    event FarmerRegistration(address _farmer);
    event BuyerRegistration(address _farmer);
    event SuccesfullyRegistered(address _farmer, uint256 index, string name, uint256 sellingPrice);
    
    /**
     * Modifier
     */
     
    modifier onlyAdmin() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    address owner;
    mapping(address => Farmer) RegisteredFarmers;
    mapping(address => Buyer) RegisteredBuyers;
    mapping(uint256 => Product) RegisteredProducts;
    mapping(uint256 => Product) RequestedProducts;
    
    uint256 currentIndexProducts;
    
    constructor() public {
        owner = msg.sender;
    }
    
    /**
     * FUNCTIONS
     */
     
    function registerFarmer(string memory farmAddress) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!RegisteredFarmers[msg.sender].active, "farmer already registered");
        RegisteredFarmers[msg.sender].active = true;
        RegisteredFarmers[msg.sender].farmAddress = farmAddress;
        RegisteredFarmers[msg.sender].farmer = msg.sender;
        emit FarmerRegistration(msg.sender);
        return RegisteredFarmers[msg.sender].active;
    }
    
    function checkFarmerRegistration() public view returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        return RegisteredFarmers[msg.sender].active;
    }
    
    function registerProduct(string memory categories, uint256 sellingprice, string memory name) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(RegisteredFarmers[msg.sender].active, "farmer not registered");
        require(sellingprice > 0, "selling price is required to be greater than 0");

        RegisteredProducts[currentIndexProducts].owner = msg.sender;
        RegisteredProducts[currentIndexProducts].index = currentIndexProducts;
        RegisteredProducts[currentIndexProducts].category = categories;
        RegisteredProducts[currentIndexProducts].active = true;
        RegisteredProducts[currentIndexProducts].name = name;
        RegisteredProducts[currentIndexProducts].sellingPrice = sellingprice;

        RegisteredFarmers[msg.sender].registeredProducts[currentIndexProducts] = RegisteredProducts[currentIndexProducts];
        RegisteredFarmers[msg.sender].registeredProductsKeys.push(currentIndexProducts);
        
        currentIndexProducts = currentIndexProducts.add(1);
        emit SuccesfullyRegistered(msg.sender, currentIndexProducts-1, name, sellingprice);
        return true;
    }

    function getFarmerRegisteredProductKeys() public view returns(uint256[] memory) {
        require(msg.sender != address(0), "Invalid sender address");
        require(RegisteredFarmers[msg.sender].active, "Famer not registered");
        return RegisteredFarmers[msg.sender].registeredProductsKeys;
    }

    function productExists(uint256 id) public view returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(id >= 0, "product id must be equal to and greater than 0");
        return RegisteredProducts[id].active;
    }
    
    
    function getTotalSupply() public view returns(uint256) {
        require(msg.sender != address(0));
        return currentIndexProducts;
    }
    
    function registerBuyer() public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!RegisteredBuyers[msg.sender].active, "Buyer already registered");
        RegisteredBuyers[msg.sender].active = true;
        RegisteredBuyers[msg.sender].buyer = msg.sender;
        emit BuyerRegistration(msg.sender);
        return true;
    }
    
    function buyProduct(uint256 productId) public payable returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(RegisteredFarmers[msg.sender].active, "You currently not registered");
        require(RegisteredProducts[productId].active, "Product already sold or does not exits");
        address productOwner = RegisteredProducts[productId].owner;
        require(productOwner != msg.sender, "Cannot buy a product from your self");
        require(RegisteredFarmers[productOwner].active, "Product seller not  not registered");
        require(productId >= 0, "Product Id must be equal to and greater than 0");
        require(msg.value > 0, "Contract cut has to be greater than 0 Eth");
        RegisteredFarmers[msg.sender].active = false;
        
        RegisteredBuyers[msg.sender].boughtProducts[productId] = RegisteredFarmers[productOwner].registeredProducts[productId];
        RegisteredBuyers[msg.sender].boughtProductsKeys.push(productId);

        return true;
    }
}