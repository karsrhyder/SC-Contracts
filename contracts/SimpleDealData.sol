pragma solidity 0.4.25;

/**
*  @title Simple Deal Hashtag Proxy
*  @dev Created in Swarm City anno 2019,
*  for the world, with love.
*  description Symmetrical Escrow Deal Contract
*  description This is the hashtag contract for creating Swarm City marketplaces.
*  It's the first, most simple approach to making Swarm City work.
*  This contract creates "SimpleDeals".
*/

import "./IMiniMeToken.sol";
import "./RepToken/DetailedERC20.sol";
import "./SimpleDealProxy.sol";

contract SimpleDealData is Ownable { 
    /// @param_deployBlock Set in the constructor. Used to log more efficiently
    uint public deployBlock;

    SimpleDealProxy public proxy;

    constructor(address _parent) public {
        /// Set creation block 
        deployBlock = block.number;
        proxy = SimpleDealProxy(_parent);
    }
}