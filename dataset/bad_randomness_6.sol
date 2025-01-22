// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract myNFT is ERC721, Ownable {
    uint256 public totalSupply;
    uint256 public incrementingSeed;  // An incrementing counter for predictable randomness
    address public trustedParty;

    event NFTMinted(address minter, uint256 tokenId);
    event RandomNumberGenerated(uint256 randomNumber);

    constructor(address _trustedParty) ERC721("ImprovedNFT", "INFT") {
        trustedParty = _trustedParty;
        incrementingSeed = 1;  // Initialize with a starting value
    }

    // Function to mint NFT based on a lucky number matching the generated random number
    function luckyMint(uint256 luckyNumber) external {
        // Generate a predictable random number based on the incrementing counter
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(incrementingSeed))) % 100;
        
        emit RandomNumberGenerated(randomNumber);

        require(randomNumber == luckyNumber, "Better luck next time!");

        _mint(msg.sender, totalSupply);  // Mint the NFT
        emit NFTMinted(msg.sender, totalSupply);
        totalSupply++;

        // Increment the seed for the next round
        incrementingSeed++;
    }

    // Function to withdraw all funds from the contract (only accessible by the owner)
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
