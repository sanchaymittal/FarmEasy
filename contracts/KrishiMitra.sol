pragma solidity >=0.4.22 <0.6.0;
contract KrishiMitra{
    struct Product{
        string description;
        address owner;
        uint price;
    }
    struct User{
        uint[] ownings;
        uint[] purchases;
    }
    struct sell{
        address seller;
       uint productID;
       uint price;
    }
    uint sellID;
    mapping(uint=>sell) public idSellMap;
    uint[] forSale ;
    mapping(address=>User)  addressUserMap;
    uint productID;
    mapping (uint=> Product) public idProductMap;
    function addProduct(string memory description, uint price) public returns(uint pID){
        productID++;
        idProductMap[productID].description = description;
        idProductMap[productID].owner = msg.sender;
        idProductMap[productID].price = price;
        addressUserMap[msg.sender].ownings.push(productID);
        pID = productID;
        listForSell(pID, price);
    }
    function listForSell(uint _productID, uint _price) public returns(uint _sellID){
        require(idProductMap[_productID].owner == msg.sender);
        sellID++;
        idSellMap[sellID].seller = msg.sender;
        idSellMap[sellID].productID = _productID;
        idSellMap[sellID].price = _price;
        forSale.push(sellID);
        _sellID = sellID;
    }
    function buy(uint _sellID) payable public returns(bool status){
        require(idSellMap[_sellID].price== msg.value);
        uint index=9999;
        idProductMap[idSellMap[_sellID].productID].owner = msg.sender;
        addressUserMap[msg.sender].purchases.push(idSellMap[_sellID].productID);
        for(uint i =0; i<addressUserMap[idSellMap[_sellID].seller].ownings.length; i++){
            if(addressUserMap[idSellMap[_sellID].seller].ownings[i]==idSellMap[_sellID].productID){
                index = i ;
                break;
            }
        }
        if(index < 9998){
             for(uint j = index;j<addressUserMap[idSellMap[_sellID].seller].ownings.length-1;j++){
                 addressUserMap[idSellMap[_sellID].seller].ownings[j]=addressUserMap[idSellMap[_sellID].seller].ownings[j+1];
             }
             delete addressUserMap[idSellMap[_sellID].seller].ownings[addressUserMap[idSellMap[_sellID].seller].ownings.length-1];
             addressUserMap[idSellMap[_sellID].seller].ownings.length--;
        }
        uint index2;
        for(uint i =0; i<addressUserMap[idSellMap[_sellID].seller].purchases.length; i++){
            if(addressUserMap[idSellMap[_sellID].seller].purchases[i]==idSellMap[_sellID].productID){
                index2 = i ;
                break;
            }
        }
        if(index2 < 9998){
              for(uint j = index2;j<addressUserMap[idSellMap[_sellID].seller].purchases.length-1;j++){
                 addressUserMap[idSellMap[_sellID].seller].purchases[j]=addressUserMap[idSellMap[_sellID].seller].purchases[j+1];
              }
             delete addressUserMap[idSellMap[_sellID].seller].purchases[addressUserMap[idSellMap[_sellID].seller].purchases.length-1];
            addressUserMap[idSellMap[_sellID].seller].purchases.length--;
        }
        uint index3;
        for(uint i =0; i<forSale.length; i++){
            if(forSale[i]==_sellID){
                index3 = i ;
                break;
            }
        }
        if(index3 < 9998){
             for(uint j = index3;j<forSale.length-1;j++){
                forSale[j]=forSale[j+1];
             }
              delete forSale[forSale.length-1];
              forSale.length--;

        }

       status = true;

    }
    function listSellable()view public returns(uint[] memory){
        return forSale;
    }
    function productCount () public  view returns(uint){
        return productID;
    }
    function getProduct(uint _productID) public view returns(string memory _description, uint _price, address _owner, uint _Id){
        _description = idProductMap[_productID].description;
        _price = idProductMap[_productID].price;
        _owner = idProductMap[_productID].owner;
        _Id = _productID;
    }
    function getUser(address _addr) public view returns(uint[] memory _ownings, uint[] memory _purchases){
        _ownings=addressUserMap[_addr].ownings;
        _purchases = addressUserMap[_addr].purchases;
    }
    function selfProfile() public view returns(uint[]memory  _ownings, uint[] memory _purchases){
        address _addr= msg.sender;
        _ownings=addressUserMap[_addr].ownings;
        _purchases = addressUserMap[_addr].purchases;
    }
    function sellDetails(uint _sellID) view public returns(string memory _description, address _owner, uint _price){
        _description  = idProductMap[idSellMap[_sellID].productID].description;
        _owner  = idProductMap[idSellMap[_sellID].productID].owner;
        _price = idSellMap[_sellID].price;
    }
}
