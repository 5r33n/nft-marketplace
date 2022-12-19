//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // console functions
import "@openzeppelin/contracts/utils/Counters.sol"; // OZ's NFT standard contracts
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

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
}
