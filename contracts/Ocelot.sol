//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract Ocelot is ERC721URIStorage, Ownable {
    // Costants
    uint256 constant NFT_PRICE = 80000000000000; //0.00008 ETH
    uint16 constant MAX_NORMAL_NFT = 510;
    uint16 constant MAX_CUSTOM_NFT = 110;
    // Variables of the contract
    uint256  private _mintedNFTs = 0;
    uint256 private _normalNFTs = 0;
    uint256 private _customNFTs = 0;
    uint16 private _availableNFTs = 0;
    string private _baseUri;
    

    // I need the deck full of cards, I do not care the order
    constructor()   ERC721("Ocelot", "OCE"){
        _normalNFTs = MAX_CUSTOM_NFT;
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
    function mintCustomOcelot(address recipient) public onlyOwner{
        require(_customNFTs < MAX_CUSTOM_NFT, "NFTs are finished");
        _safeMint(recipient, _customNFTs);
        _customNFTs++;
        _mintedNFTs++;
        
    }
    // for lazy people that do not want to pass the address
    function mintCustomOcelot() public onlyOwner{
        return mintCustomOcelot(msg.sender);
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
        return _normalNFTs - MAX_CUSTOM_NFT;
    }
    // how much reserved NFTs are on the chain
    function circulationCustom() public view returns (uint256) {
        return _customNFTs;
    }
    // I need this to start the sale
    function setAvailbleNFTs(uint16 supply) public {
        _availableNFTs += supply;
    }

    function setBaseUri(string calldata baseUri) public{
        _baseUri = baseUri;
    }
        
    // OVERRIDE
    function _baseURI() override internal view virtual returns (string memory) {     
        return _baseUri;
    }
}
