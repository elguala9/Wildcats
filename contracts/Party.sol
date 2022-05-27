//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract Party is ERC1155, Ownable {
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
        _sets = 4;
        _NFTs[0].supply = 20;
        _NFTs[0].price = 2000000000000000000; //WEI

        _NFTs[1].supply = 10;
        _NFTs[1].price = 3000000000000000000; //WEI

        _NFTs[2].supply = 20;
        _NFTs[2].price = 2000000000000000000; //WEI

        _NFTs[3].supply = 10;
        _NFTs[3].price = 3000000000000000000; //WEI
    }

    // create a single new set
    function createSet(uint256 supply, uint256 price) public onlyOwner{      
        uint256 new_set = _sets;
        _sets++;
        setSupply(new_set, supply);
        setPrice(new_set, price);
        //_NFTs[new_set].uri = uri;
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
    function setUri(string calldata uri) public onlyOwner{
        _baseURI = uri;
    }
    // active the sale
    function setSale(uint256 set, bool state) public onlyOwner{
        _checkSet(set);
        require(_NFTs[set].saleIsActive != state, "Sale is already in this state");
        _NFTs[set].saleIsActive = state;
    }

    // classic mint function
    function mintParty(address recipient, uint256 set, uint256 amount) public payable{
        _checkSet(set);
        require(amount > 0, "Amount need to be higher than 0");
        require(_NFTs[set].saleIsActive, "Sale not active for the set chosen");
        require( msg.value >= _NFTs[set].price * amount, "The Ether sent is not enough");
        require(_NFTs[set].circulation < _NFTs[set].supply , "No more NFTs are available for the set choose");
        require(_NFTs[set].circulation + amount <= _NFTs[set].supply , "Amount too high for the current circulation");

        _mint(recipient, set, amount, "");
        _NFTs[set].circulation+=amount;
    }

    // for lazy people that do not want to pass the address
    function mintParty(uint256 set, uint256 amount) public payable {
        mintParty(msg.sender, set, amount);
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }


    // GET UTILITIES
    // check if the set exist
    function _checkSet(uint256 set) view internal {
        require(set < _sets, "This set does not exist");
    }

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