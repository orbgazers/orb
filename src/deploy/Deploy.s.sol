pragma solidity ^0.8.10;
import "forge-std/Script.sol";
import "../ZuniswapV2Factory.sol";
import "../ZuniswapV2Router.sol";
import "../OrbCoin.sol";
import "../Markets.sol";
import "../ERC20Mintable.sol";

contract DeployLocal is Script {
    function run() external {
        vm.startBroadcast();

        // Using CREATE2 (specifying salt) makes deployment address predictable no matter the chain,
        // if the bytecode does not change. (Note that Foundry omits the matadata hash by default:
        // https://github.com/foundry-rs/foundry/pull/1180)

        // Not used for local deployments because it needs the CREATE2 deployer deployed at
        // 0x4e59b44847b379578588920ca78fbf26c0b4956c and that's not the case on the Anvil chain.

        address factory = address(new ZuniswapV2Factory());
        console2.log("ZuniswapV2Factory address", factory);
        address router = address(new ZuniswapV2Router(factory));
        console2.log("ZuniswapV2Router address", router);
        address orbcoin = address(new OrbCoin());
        console2.log("OrbCoin address", orbcoin);
        address backing = address(new ERC20Mintable("Backing", "BAK"));
        console2.log("BackingCoin token address", backing);
        address markets = address(new Markets(orbcoin, backing));
        console2.log("Markets address", markets);

        ERC20Mintable(backing).mint(msg.sender, 1000 ether);

        vm.stopBroadcast();
    }
}

contract DeployPublic is Script {
    bytes32 private constant salt = bytes32(uint256(4269));

    function run() external {
        vm.startBroadcast();

        // Using CREATE2 (specifying salt) makes deployment address predictable no matter the chain,
        // if the bytecode does not change. (Note that Foundry omits the matadata hash by default:
        // https://github.com/foundry-rs/foundry/pull/1180)

        // Not used for local deployments because it needs the CREATE2 deployer deployed at
        // 0x4e59b44847b379578588920ca78fbf26c0b4956c and that's not the case on the Anvil chain.

        // USDC on Cronos
        address usdc = 0xc21223249CA28397B4B6541dfFaEcC539BfF0c59;

        address factory = address(new ZuniswapV2Factory{salt: salt}());
        console2.log("Factory address: ", factory);
        address router = address(new ZuniswapV2Router{salt: salt}(factory));
        console2.log("Router address: ", router);
        address orbcoin = address(new OrbCoin{salt: salt}());
        console2.log("Orbcoin address", orbcoin);
        address markets = address(new Markets{salt: salt}(orbcoin, usdc));
        console2.log("Markets address", markets);

        vm.stopBroadcast();
    }
}
