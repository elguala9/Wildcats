//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract Sociable is ERC1155, Ownable {
    using Strings for uint256;
    //structs
    struct structNFT {
        uint256 circulation;
        uint256 supply;
        //string uri;
        bool saleIsActive;
        uint256 price;
    }
    //variables
    uint256 private _sets = 0;
    string private _baseURI;
    mapping (uint256 => structNFT) private _NFTs;


    constructor() ERC1155(""){
        _sets = 2;
        _NFTs[0].supply = 60;
        _NFTs[0].price = 0; //WEI
        _NFTs[1].supply = 30;
        _NFTs[1].price = 0; //WEI

    }

    // create a single new set
    function createSet(uint256 supply, uint256 price/*, string calldata uri*/) public onlyOwner{      
        uint256 new_set = _sets;
        _sets++;
        setSupply(new_set, supply);
        setPrice(new_set, price);
        //_NFTs[new_set].uri = uri;
    }
    

    // check if the set exist
    function _checkSet(uint256 set) view internal {
        require(set < _sets, "This set does not exist");
    }

    // I can set the supply in every moment
    function setSupply(uint256 set, uint256 supply) public onlyOwner{
        _checkSet(set);
        _NFTs[set].supply = supply;
    }
    // I can set the supply in every moment
    function setPrice(uint256 set, uint256 price) public onlyOwner{
        _checkSet(set);
        _NFTs[set].price = price;
    }
    // set the uri
    function setUri(/*uint256 set,*/ string calldata uri) public onlyOwner{
        /*checkSet(set);
        _NFTs[set].uri = uri;*/
        _baseURI = uri;
    }
    // active the sale
    function activeSale(uint256 set) public onlyOwner{
        _checkSet(set);
        require(_NFTs[set].saleIsActive = true, "Sale is already active");
        _NFTs[set].saleIsActive = true;
    }

    // classic mint function
    function mintSociable(address recipient, uint256 set, uint256 amount) public payable{
        _checkSet(set);
        require(amount > 0, "Amount need to be higher than 0");
        require(_NFTs[set].saleIsActive, "Sale not active for the set chosen");
        require( msg.value >= _NFTs[set].price * amount, "The Ether sent is not enough");
        require(_NFTs[set].circulation < _NFTs[set].supply , "No more NFTs are available for the set choosed");
        require(_NFTs[set].circulation + amount <= _NFTs[set].supply , "Amount too high for the current circulation");

        _mint(recipient, set, amount, "");
        _NFTs[set].circulation+=amount;
    }

    // for lazy people that do not want to pass the address
    function mintSociable(uint256 set, uint256 amount) public payable {
        mintSociable(msg.sender, set, amount);
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }


    // GET UTILITIES
    // override the ERC1155 classic function
    function uri(uint256 set) public view override returns (string memory){
        _checkSet(set);
        //return string(abi.encodePacked(_NFTs[set].uri, Strings.toString(set)));
        return string(abi.encodePacked(_baseURI, Strings.toString(set)));
    }
    function sets() public view returns (uint256){
        return _sets;
    }
    function totalCirculation() public view returns (uint256){
        uint256 circulation = 0;
        for(uint256 set = 0; set < _sets; set++)
            circulation+=_NFTs[set].circulation;
        return circulation;
    }
    function getSet(uint256 set) public view returns (structNFT memory){
        _checkSet(set);
        return _NFTs[set];
    }

    


}