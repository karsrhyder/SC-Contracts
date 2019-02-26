pragma solidity 0.4.25;

contract SimpleDeal {

    struct Data { mapping(bytes32=>bool) items; }

    function setItem(Data storage self, bytes32 _itemHash) public returns (bool) {
        if (self.items[_itemHash])
            return false; //already there
        self.items[_itemHash] = true;
        return true;
    }
}