pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Mintable.sol";

contract GenesisNFT is ERC721Full, ERC721Mintable {
  	address payable beneficiary;
  	uint256 basePrice;
  	uint256 multiplier; 
  	uint256 divisor;
  	uint256 limit;

  	uint256 unitsCreated;
  	uint256 currentPrice;

  	event TokenPurchase(address indexed purchaser, uint256 indexed serialNumber, uint256 price);

  // "GenesisNFT", "GNFT", "0x85A363699C6864248a6FfCA66e4a1A5cCf9f5567", "100000000000000000", 11, 10, 100

  constructor(string memory name, string memory symbol, address payable _beneficiary, uint256 _basePrice, uint256 _multiplier, uint256 _divisor, uint256 _limit) 													ERC721Full(name, symbol ) public {
  	beneficiary = _beneficiary;
  	basePrice = _basePrice;
  	multiplier = _multiplier; 
  	divisor = _divisor;
  	limit = _limit;

  	unitsCreated = 0; // regardless the built-in function keeping count, holding a separate registr
  	currentPrice = basePrice;
  }

  // FALLBACK
  function() external payable {
  	buy();
  }

  function buy() payable public {
  	require(unitsCreated < limit, "too many units created");
  	require(msg.value >= currentPrice, "you need to send more ETH");

  	uint256 refund = msg.value - currentPrice;

  	msg.sender.transfer(refund);
  	beneficiary.transfer(currentPrice);

  	safeMint(msg.sender, unitsCreated); // sequential token ID
  	emit TokenPurchase(msg.sender, unitsCreated, currentPrice);

  	unitsCreated++;
  	currentPrice = currentPrice.mul(multiplier).div(divisor); // * 11 / 10
  }

}