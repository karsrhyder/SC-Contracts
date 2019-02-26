pragma solidity 0.4.25;

import "./SimpleDeal.sol";

contract HashtagContract {

    SimpleDeal.Data items;

    function newItem() public {
        // Here, all variables of type Set.Data have
        // corresponding member functions.
        // The following function call is identical to
        // `Set.insert(knownValues, value)`
        require(SimpleDeal.setItem(items, "0x0"));
    }
}