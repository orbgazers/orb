pragma solidity ^0.8.10;
import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";

contract OutcomeToken is ERC20, Owned {
    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol, 18)
        Owned(msg.sender)
    {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
