pragma solidity ^0.8.10;
import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";

contract ERC20Mintable is ERC20, Owned {
    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol, 18)
        Owned(msg.sender)
    {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // reverse order overload to be compatible with Zuniswap
    function mint(uint256 amount, address to) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
