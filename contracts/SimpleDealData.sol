pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;
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

    /// @param_itemsHash Array with all items hashes.
    bytes32[] public itemHashes;

    /// @notice itemStatuses enum
    enum itemStatuses {
		Open,
        Funded,
		Done,
		Disputed,
		Resolved,
		Cancelled
    }

    /// @param_dealStruct The deal object.
    /// @param_status Coming from itemStatuses enum.
    /// Statuses: Open, Done, Disputed, Resolved, Cancelled
    /// @param_hashtagFee The value of the hashtag fee is stored in the deal. This prevents the hashtagmaintainer to influence an existing deal when changing the hashtag fee.
    /// @param_dealValue The value of the deal (SWT)
    /// @param_provider The address of the provider
	/// @param_deals Array of deals made by this hashtag

    struct itemStruct {
        itemStatuses status;
        uint hashtagFee;
        uint itemValue;
        uint providerRep;
        uint seekerRep;
        address providerAddress;
        address seekerAddress;
        bytes32 itemMetadataHash;
        bytes32[] replies;
        address[] repliers;
        uint creationBlock;
    }

    mapping(bytes32=>itemStruct) public items;

    SimpleDealProxy public proxy;

    constructor(address _parent) public {
        /// Set creation block 
        deployBlock = block.number;
        proxy = SimpleDealProxy(_parent);
    }

    function setItem(bytes32 _itemHash, uint _block, address _seeker) public {
        itemStruct memory item;
        item.status = itemStatuses.Open;
        item.hashtagFee = proxy.hashtagFee();
        item.seekerRep = proxy.SeekerRep().balanceOf(_seeker);
        item.seekerAddress = _seeker;
        item.creationBlock = _block;
        itemHashes.push(_itemHash);
        items[_itemHash] = item;
    }

    function readItemData(bytes32 _itemHash) public view returns (
            itemStatuses status, 
            address seekerAddress,
            uint seekerRep,
            uint numberOfReplies)
        {
        return (
            items[_itemHash].status,
            items[_itemHash].seekerAddress,
            items[_itemHash].seekerRep,
            items[_itemHash].replies.length);
    }
}