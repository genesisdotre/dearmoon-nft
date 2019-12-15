pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract GenesisNFT is ERC721Full, Ownable {
  	string public ipfshash;
  	address payable public beneficiary;
  	uint256 public basePrice;
  	uint256 public multiplier; 
  	uint256 public divisor;
  	uint256 public limit;

  	uint256 public serialNumber;
  	uint256 public currentPrice;

  	event TokenPurchase(address indexed purchaser, uint256 indexed serialNumber, uint256 price);

  // "GenesisNFT", "GNFT", "QmbtWkKnstd3Co3rWcD7woYZAKxk7yyzmf3DcGTM5fBc2N", "0x85A363699C6864248a6FfCA66e4a1A5cCf9f5567", "100000000000000000", 11, 10, 100
  // price 0.1 ETH, each next being 11/10 of the previous price, limit to 100
  constructor(string memory name, string memory symbol, string memory _ipfshash, address payable _beneficiary, uint256 _basePrice, uint256 _multiplier, uint256 _divisor, uint256 _limit) ERC721Full(name, symbol) public {
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

  	uint256 refund = msg.value - currentPrice; // we've just checkeed it's >= do we need safe math?

  	msg.sender.transfer(refund);
  	beneficiary.transfer(currentPrice);

  	_safeMint(msg.sender, serialNumber); // internal function
  	emit TokenPurchase(msg.sender, serialNumber, currentPrice);

  	serialNumber++;
  	currentPrice = currentPrice.mul(multiplier).div(divisor); // * 11 / 10
  }

  // This is if we want to move to DAO fundraising
  // Allowing owner to change it, in case beneficiary is some dumb multisig
  function changeBeneficiary(address payable newBeneficiary) public {
    require(msg.sender == beneficiary || isOwner(), "sender must be either owner or beneficiary");
    require(newBeneficiary != address(0), "new benficiary cannot be empty");
    beneficiary = newBeneficiary;
  }


}