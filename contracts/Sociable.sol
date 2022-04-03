//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sociable is ERC1155, Ownable {
    // Constants
    uint256 constant NFT_PRICE = 80000000000000; //0.00008 ETH
    //structs
    struct structNFT {
        uint256 circulation;
        uint256 supply;
        string uri;
        bool saleIsActive;
    }
    //variables
    uint256 private _sets = 0;
    uint256 private _totalCirculation = 0;
    mapping (uint256 => structNFT) private _NFTs;


    constructor() ERC1155(""){
        _sets = 2;
    }
    // increment the number of possible sets
    function addSets(uint256 sets) public onlyOwner{
        _sets += sets;
    }
    // I can set the supply in every moment
    function setSupply(uint256 set, uint256 supply) public onlyOwner{
        require(set > _sets, "This set does not exist");
        _NFTs[set].supply = supply;
    }
    // set the uri
    function setUri(uint256 set, string calldata uri) public onlyOwner{
        require(set > _sets, "This set does not exist");
        _NFTs[set].uri = uri;
    }
    // active the sale
    function activeSale(uint256 set) public onlyOwner{
        require(set > _sets, "This set does not exist");
        require(_NFTs[set].saleIsActive = true, "Sale is already active");
        _NFTs[set].saleIsActive = true;
    }

    // classic mint function
    function mintSociable(address recipient, uint256 set, uint256 amount) public payable{
        require(set > _sets, "This set does not exist");
        require(_NFTs[set].saleIsActive = false, "Sale not active for the set chosen");
        require(NFT_PRICE <= msg.value, "The Ether sent is not enough");
        require(_NFTs[set].circulation >= _NFTs[set].supply , "No more NFTs are available for the set choosed");
        require(_NFTs[set].circulation + amount > _NFTs[set].supply , "Amount too high for the current circulation");

        _mint(recipient, set, amount, "");

        _NFTs[set].circulation++;
        _totalCirculation++;
    }

    // for lazy people that do not want to pass the address
    function mintSociable(uint256 set, uint256 amount) public payable {
        mintSociable(msg.sender, set, amount);
    }

    // GET UTILITIES
    function circulation(uint256 set) public view returns (uint256){
        return _NFTs[set].circulation;
    }
    function supply(uint256 set) public view returns (uint256){
        return _NFTs[set].supply;
    }
    // override the ERC1155 classic function
    function uri(uint256 set) public view override returns (string memory){
        return _NFTs[set].uri;
    }
    function saleIsActive(uint256 set) public view returns (bool){
        return _NFTs[set].saleIsActive;
    }




}