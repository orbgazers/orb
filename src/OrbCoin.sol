pragma solidity ^0.8.10;
import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";

contract OrbCoin is ERC20, Owned {
    constructor() ERC20("OrbCoin", "ORB", 18) Owned(msg.sender) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}
