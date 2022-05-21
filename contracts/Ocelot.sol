//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract Ocelot is ERC721, Ownable {
    // Costants
    uint256 constant NFT_PRICE = 80000000000000; //0.00008 ETH
    uint16 constant MAX_NORMAL_NFT = 510;
    uint16 constant MAX_CUSTOM_NFT = 110;
    // Variables of the contract
    uint256 private _normalNFTs = 0;
    uint256 private _customNFTs = 0;
    uint16 private _availableNFTs = 0;
    string private _baseUri;
    

    // I need the deck full of cards, I do not care the order
    constructor()   ERC721("Ocelot", "OCE"){
        
    }
    
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function getBalance() public view returns (uint256) {
        return  address(this).balance;
    }

    

    // mint the normal NFT
    function mintOcelot() public payable{
        require(_normalNFTs + 1 < MAX_NORMAL_NFT, "NFTs are finished");
        require(_availableNFTs > 0, "No NFTs are available");
        require(NFT_PRICE <= msg.value, "The Ether sent is not enough");
        _mint(msg.sender, MAX_CUSTOM_NFT + _normalNFTs);
        _normalNFTs++;
        _availableNFTs--;
    }


    // 0 - 199 token ID: custom rare 
    function mintCustomOcelot() public onlyOwner{
        mintCustomOcelot(msg.sender);
    }
    // mint the custom Ocelot
    function mintCustomOcelot(address recipient) public onlyOwner{
        require(_customNFTs < MAX_CUSTOM_NFT, "NFTs are finished");
        _mint(recipient, _customNFTs);
        _customNFTs++;
    }
    
    
    // I need this to start the sale
    function setAvailbleNFTs(uint16 supply) public onlyOwner{
        require(supply + _normalNFTs + _availableNFTs <= MAX_NORMAL_NFT, "Supply bigger than CAP");
        _availableNFTs += supply;
    }

    function setBaseUri(string calldata base_uri) public onlyOwner{
        _baseUri = base_uri;
    }

    //GETTER
    // how much normal NFTs are on the chain
    function circulationNormal() public view returns (uint256) {
        return _normalNFTs;
    }
    // how much reserved NFTs are on the chain
    function circulationCustom() public view returns (uint256) {
        return _customNFTs;
    }
    function getPrice() public pure returns (uint256) {
        return NFT_PRICE;
    }

    function availableNFTs() public view returns (uint16) {
        return _availableNFTs;
    }

    function customNftsOwned(address nft_owner) public view returns (uint64){
        return nftsOwned(nft_owner, 0, _customNFTs);
    }

    function normalNftsOwned(address nft_owner) public view returns (uint64){
        return nftsOwned(nft_owner, MAX_CUSTOM_NFT, _normalNFTs);
    }

    function nftsOwned(address nft_owner, uint256 start_NFT, uint256 NFTs) private view returns (uint64){
        uint64 nfts = 0;
        for(uint256 i = start_NFT; i < start_NFT + NFTs; i++){
            if(ownerOf(i) == nft_owner)
                nfts++;
        }

        return nfts;
    }

    function maxCustomNFTs() public pure returns (uint16){
        return MAX_CUSTOM_NFT;
    }

    function maxNormalNFTs() public pure returns (uint16){
        return MAX_NORMAL_NFT;
    }
    

    //OVERRIDE
    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }
}
