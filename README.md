# NFT Marketplace

This basic NFT marketplace lets you surf and purchase others' NFTs and mint your own.

# Installation

First clone the repo using 

`git clone https://github.com/5r33n/nft-marketplace.git`

Then install the dependencies using

`npm i`

And finally run it via

`npm start`

## `NFTMarketplace.sol` Smart Contract

The smart contract contains the following functions which are presented below with their purposes.

### `createToken(tokenURI, price)`

This function mints and lists the token the first time it is created; it is used in the "List Your NFT" page.

### `getAllNFTs()`

This function iterates among all the NFTs listed in the contract and returns them as `tokens`.

### `getMyNFTs()`

This function returns all the NFTs that the current user is the owner or the seller of. It firstly gets count of all the NFTs belonging to the user and then creates an array of the relevant NFTs and returns them as `itmes`.

### `executeSale(tokenId)`

This function is called when an NFT with `tokenId` gets to be sold, i.e. transfer the ownership of the token to another user.

## JS Components in `src/components/`

The JS files in this directory connect the smart contract to the users via an explorer.

### `Marketplace.js`

This is the homepage of the website where all the NFTs are listed.

### `Navbar.js`

It contains the "Connect Wallet" button.

### `NFTPage.js`

When the user clicks on an NFT they are redirected to this page where they can see all the details about it and they can purchase it as well.

### `Profile.js`

This is where a user can showcase their minted NFTs.

### `SellNFT.js`

Using this page a user can upload and mint their NFT.
