pragma solidity ^0.8.10;
import "./ERC20Mintable.sol";

contract OutcomeToken is ERC20Mintable {
    constructor(string memory _name, string memory _symbol)
        ERC20Mintable(_name, _symbol)
    {}
}
