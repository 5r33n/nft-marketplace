//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // console functions
import "@openzeppelin/contracts/utils/Counters.sol"; // OZ's NFT standard contracts
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/* Errors */
error NFTMP__InsufficientPrice();
error NFTMP__NegativePrice();
error NFTMP__InsufficientAskingPrice();
error NFTMP__NotOwner();

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    // _tokenIds has the most recent minted tokenId
    Counters.Counter private _tokenIds;
    // _itemsSold keeps track of the num of items sold on the marketplace
    Counters.Counter private _itemsSold;
    // owner is the contract address that created the smart contract
    address payable owner;
    // the fee charged by the marketplace to be allowed to list an NFT
    uint256 listPrice = 0.01 ether;

    // the struct to store info about a listed token
    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    // the event emitted when a token is successfully listed
    event TokenListedSuccess(
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool currentlyListed
    );

    // mapping tokenId to token info; helpful when retrieving details about a tokenId
    mapping(uint256 => ListedToken) private idToListedToken;

    constructor() ERC721("NFTMarketplace", "NFTM") {
        owner = payable(msg.sender);
    }

    // this function lists the token the first time it's created.
    // it's used in "List Your NFT" page
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        // increment the tokenId counter, keeping track of the num of minted NFTs
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        // minting NFT with tokenId newTokenId to the address who called createToken
        _safeMint(msg.sender, newTokenId);

        // map the tokenId to the tokenURI (which is an IPFS URL with the NFT metadata)
        _setTokenURI(newTokenId, tokenURI);

        // helper function to update global vars and emit an event
        createListedToken(newTokenId, price);

        return newTokenId;
    }

    function createListedToken(uint256 tokenId, uint256 price) private {
        // checking ETH sufficiency
        if (msg.value == listPrice) return NFTMP__InsufficientPrice();
        // sanity check
        if (price <= 0) return NFTMP__NegativePrice();

        // update the mapping of tokenIds to token details; for retrieval functions
        idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );

        _transfer(msg.sender, address(this), tokenId);

        // frontend parses this msg and updates the end user
        emit TokenListedSuccess(tokenId, address(this), msg.sender, price, true);
    }

    // this function returns all the NFTs currently listed to be sold on the marketplace
    function getAllNFTs() public view returns (ListedToken[] memory) {
        uint nftCount = _tokenIds.current();
        ListedToken[] memory tokens = new ListedToken[](nftCount);
        uint currentIndex = 0;
        uint currentId;

        // right now currentlyListed is true for all; we'll have to filter it out if it becomes
        // false in the future
        for (uint i = 0; i < nftCount; i++) {
            currentId = i + 1;
            ListedToken storage currentItem = idToListedToken[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }

        return tokens;
    }

    // returns all the NFTs that the current user is owner or seller in
    function getMyNFTs() public view returns (ListedToken[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        uint currentId;

        // get count of all NFTs belonging to the user
        for (uint i = 0; i < totalItemCount; i++) {
            if (
                idToListedToken[i + 1].owner == msg.sender ||
                idToListedToken[i + 1].seller == msg.sender
            ) {
                itemCount += 1;
            }
        }

        // creating array to store relevant NFTs
        ListedToken[] memory items = new ListedToken[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (
                idToListedToken[i + 1].owner == msg.sender ||
                idToListedToken[i + 1].seller == msg.sender
            ) {
                currentId = i + 1;
                ListedToken storage currentItem = idToListedToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function executeSale(uint256 tokenId) public payable {
        uint price = idToListedToken[tokenId].price;
        address seller = idToListedToken[tokenId].seller;
        if (msg.value != price) return NFTMP__InsufficientAskingPrice();

        // update token details
        idToListedToken[tokenId].currentlyListed = true;
        idToListedToken[tokenId].seller = payable(msg.sender);
        _itemsSold.increment();

        // transfer token to new owner
        _transfer(address(this), msg.sender, tokenId);
        // approve marketplace to sell NFTs on your behalf
        approve(address(this), tokenId);

        // transfer listing fee to the marketplace creator
        payable(owner).transfer(listPrice);
        // transfer the proceeds from the sale to the seller of the NFT
        payable(seller).transfer(msg.value);
    }

    /* Helper Functions */

    function updateListPrice(uint256 _listPrice) public payable {
        if (owner != msg.sender) return NFTMP__NotOwner();
        listPrice = _listPrice;
    }

    function getListPrice() public view returns (uint256) {
        return listPrice;
    }

    function getLatestIdToListedToken() public view returns (ListedToken memory) {
        uint256 currentTokenId = _tokenIds.current();
        return idToListedToken[currentTokenId];
    }

    function getListedTokenForId(uint256 tokenId) public view returns (ListedToken memory) {
        return idToListedToken[tokenId];
    }

    function getCurrentToken() public view returns (uint256) {
        return _tokenIds.current();
    }
}
