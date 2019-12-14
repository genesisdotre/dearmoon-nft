pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Mintable.sol";

contract GenesisNFT is ERC721Full, ERC721Mintable {
  	address payable beneficiary;
  	uint256 basePrice;
  	uint256 multiplier; 
  	uint256 divisor;
  	unit256 limit;

  	uint256 unitsCreated;
  	uint256 currentPrice;

  // "GenesisNFT", "GNFT", "0x85A363699C6864248a6FfCA66e4a1A5cCf9f5567", "100000000000000000", 11, 10, 100

  constructor(string name, string symbol, address _beneficiary, uint256 _basePrice, uint256 _multiplier, uint256 _divisor, uint256 _limit) 													ERC721Full(name, symbol ) public {
  	beneficiary = _beneficiary;
  	basePrice = _basePrice;
  	multiplier = _multiplier; 
  	divisor = _divisor;
  	limit = _limit;

  	unitsCreated = 0; // regardless the built-in function keeping count, holding a separate registr
  	currentPrice = basePrice;
  }

  fallback() payable public {
  	buy();
  }

  buy() payable public {

  	currentPrice = currentPrice.mul(multiplier).div(divisor); // * 11 / 10
  }

}