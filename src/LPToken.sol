pragma solidity ^0.8.10;
import "./ERC20Mintable.sol";

contract LPToken is ERC20Mintable {
    uint256 public marketID;

    // TODO customize name / symbol per market
    constructor(uint256 _marketID) ERC20Mintable("Orb LP Token", "ORBLP") {
        marketID = _marketID;
    }
}
