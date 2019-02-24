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
import "./SimpleDealData.sol";

contract SimpleDealLogic is Ownable { 
    uint public deployBlock;
    SimpleDealProxy public proxy;
    SimpleDealData public data;

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

    constructor(address _parent, SimpleDealData _data) public {
        /// Set creation block 
        deployBlock = block.number;
        proxy = SimpleDealProxy(_parent);
        data = SimpleDealData(_data);
    }

    function newItem(
        bytes32 _itemHash, 
        uint _itemValue, 
        bytes32 _itemMetadataHash
    ) public { 
        /// @dev make sure there is enough to pay the hashtag fee later on
        require (proxy.hashtagFee() / 2 <= _itemValue, "Overflow protection: item value");
        require (_itemValue + proxy.hashtagFee() / 2 >= _itemValue, "Overflow protection: total value");

        /// @dev if deal already exists don't allow to overwrite it
        //require (data.items(_itemHash).hashtagFee() == 0 && data.items(_itemHash).itemValue() == 0, "hashtagFee and itemValue must be 0");

        /// @dev The Seeker pays half of the hashtagFee to the Maintainer
        //require(token.transfer(proxy.payoutAddress(), proxy.hashtagFee() / 2), "");

        /// @dev Initialize item struct
        itemStruct memory item;
        item.status = itemStatuses.Open;
        item.hashtagFee = proxy.hashtagFee();
        item.itemValue = _itemValue;
        item.seekerRep = proxy.SeekerRep().balanceOf(tx.origin);
        item.seekerAddress = tx.origin;
        item.itemMetadataHash = _itemMetadataHash;
        item.creationBlock = block.number;
        //items[_itemHash] = item;

        //data.setItem(_itemHash, item);
        data.delegatecall(bytes4(keccak256("setItem(bytes32, uint, address)")), _itemHash, block.number, tx.origin); 

    }
}