// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract OrbToken is ERC20PresetMinterPauser {
// he account that deploys the contract will be granted the minter and pauser roles, as well as the default admin role.
    constructor(uint256 initialSupply) ERC20PresetMinterPauser("OrbToken", "ORB") {
        _mint(msg.sender, initialSupply);
    }
}