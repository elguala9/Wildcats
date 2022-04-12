//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract Ocelot is ERC721URIStorage, Ownable {
    // Costants
    uint256 constant NFT_PRICE = 80000000000000; //0.00008 ETH
    uint16 constant MAX_NORMAL_NFT = 750;
    uint16 constant MAX_CUSTOM_NFT = 200;
    uint16 constant MAX_RESERVED_NFT = 50;
    // Variables of the contract
    uint256  private _mintedNFTs = 0;
    uint256 private _normalNFTs = 0;
    uint256 private _reservedNFTs = 0;
    uint256 private _customNFTs = 0;
    uint16 private _availableNFTs = 0;
    

    // I need the deck full of cards, I do not care the order
    constructor(string memory name, string memory symbol)   ERC721(name, symbol){
        _normalNFTs = MAX_RESERVED_NFT+MAX_CUSTOM_NFT;
        _reservedNFTs = MAX_CUSTOM_NFT;
    }
    
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function getBalance() public view onlyOwner returns (uint256) {
        return  address(this).balance;
    }

    // mint a token wihtout setting the URI 
    function mintOcelot(address recipient) public payable {
        require(_normalNFTs < MAX_NORMAL_NFT, "NFTs are finished");
        require(_availableNFTs > 0, "No NFTs are available");
        require(NFT_PRICE <= msg.value, "The Ether sent is not enough");
        _safeMint(recipient, _normalNFTs);
        
        _normalNFTs++;
        _mintedNFTs++;
    }

    // for lazy people that do not want to pass the address
    function mintOcelot() public payable{
        mintOcelot(msg.sender);
    }

    // 0 - 199 token ID: custom rare 
    function mintCustomOcelot(address recipient, string calldata uri) public onlyOwner{
        require(_customNFTs < MAX_CUSTOM_NFT, "NFTs are finished");
        _safeMint(recipient, _customNFTs);
        _setTokenURI(_customNFTs, uri);
        _customNFTs++;
        _mintedNFTs++;
    }
    // for lazy people that do not want to pass the address
    function mintCustomOcelot(string calldata uri) public onlyOwner{
        return mintCustomOcelot(msg.sender, uri);
    }

    // 200 - 249 token ID: common reserved
    function mintReservedOcelot(address recipient, string calldata uri) public onlyOwner{
        require(_reservedNFTs < MAX_RESERVED_NFT, "NFTs are finished");
        _safeMint(recipient, _reservedNFTs);
        _setTokenURI(_reservedNFTs, uri);
        _reservedNFTs++;
        _mintedNFTs++;
    }
    // for lazy people that do not want to pass the address
    function mintReservedOcelot(string calldata uri) public onlyOwner{
        return mintReservedOcelot(msg.sender, uri);
    }

    // 
    function setUriNFT(uint256 tokenId, string calldata tokenURI) public onlyOwner {
        _setTokenURI(tokenId, tokenURI);
    }
    // how much NFTs are on the chain
    function circulation() public view returns (uint256) {
        return _mintedNFTs;
    }
    // how much normal NFTs are on the chain
    function circulationNormal() public view returns (uint256) {
        return _normalNFTs- (MAX_RESERVED_NFT+MAX_CUSTOM_NFT);
    }
    // how much reserved NFTs are on the chain
    function circulationReserved() public view returns (uint256) {
        return _reservedNFTs - MAX_CUSTOM_NFT;
    }
    // how much reserved NFTs are on the chain
    function circulationCustom() public view returns (uint256) {
        return _customNFTs;
    }
    // I need this to start the sale
    function setAvailbleNFTs(uint16 supply) public {
        _availableNFTs += supply;
    }
}
