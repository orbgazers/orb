pragma solidity ^0.8.10;
import "./ERC20Mintable.sol";

contract OrbCoin is ERC20Mintable {
    constructor() ERC20Mintable("OrbCoin", "ORB") {}
}
