pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";

contract GenesisNFT is ERC721Full {
  	string ipfshash;
  	address payable beneficiary;
  	uint256 basePrice;
  	uint256 multiplier; 
  	uint256 divisor;
  	uint256 limit;

  	uint256 serialNumber;
  	uint256 currentPrice;

  	event TokenPurchase(address indexed purchaser, uint256 indexed serialNumber, uint256 price);

  // "GenesisNFT", "GNFT", "QmbtWkKnstd3Co3rWcD7woYZAKxk7yyzmf3DcGTM5fBc2N", 0x85A363699C6864248a6FfCA66e4a1A5cCf9f5567", "100000000000000000", 11, 10, 100
  // price 0.1 ETH, each next being 11/10 of the previous price, limit to 100
  constructor(string memory name, string memory symbol, string memory _ipfshash, address payable _beneficiary, uint256 _basePrice, uint256 _multiplier, uint256 _divisor, uint256 _limit) 													ERC721Full(name, symbol ) public {
  	ipfshash = _ipfshash;
  	beneficiary = _beneficiary;
  	basePrice = _basePrice;
  	multiplier = _multiplier; 
  	divisor = _divisor;
  	limit = _limit;

  	serialNumber = 0;
  	currentPrice = basePrice;
  }

  // FALLBACK
  function() external payable {
  	buy();
  }

  function buy() payable public {
  	require(serialNumber < limit, "too many units created");
  	require(msg.value >= currentPrice, "you need to send more ETH");

  	uint256 refund = msg.value - currentPrice;

  	msg.sender.transfer(refund);
  	beneficiary.transfer(currentPrice);

  	_safeMint(msg.sender, serialNumber); // internal function
  	emit TokenPurchase(msg.sender, serialNumber, currentPrice);

  	serialNumber++;
  	currentPrice = currentPrice.mul(multiplier).div(divisor); // * 11 / 10
  }

}