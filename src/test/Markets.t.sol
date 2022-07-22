pragma solidity ^0.8.10;
import "forge-std/Test.sol";
import {MarketInfo, Market, Markets} from "../Markets.sol";
import "../OrbCoin.sol";

contract MarketsTest is Test {
    OrbCoin private orbCoin;
    MarketInfo private ab;
    uint256 public constant BASE18 = 1 ether;

    function setUp() public {
        orbCoin = new OrbCoin();

        string[] memory names = new string[](2);
        names[0] = "Token A";
        names[1] = "Token B";

        string[] memory symbols = new string[](2);
        symbols[0] = "A";
        symbols[1] = "B";

        uint64[] memory prices = new uint64[](2);
        prices[0] = uint64(BASE18 / 2);
        prices[1] = uint64(BASE18 / 2);

        ab = MarketInfo({
            name: "AB",
            description: "it's A or B, baby",
            owner: address(this),
            arbiter: address(this),
            settlement: address(this), // TODO
            outcomeNames: names,
            outcomeSymbols: symbols,
            initialLiquidity: 10_000,
            stopTime: uint64(block.timestamp + 7_000),
            settlementTime: uint64(block.timestamp + 7_000),
            initialPrices: prices
        });
    }

    function testOne() public {
        Markets markets = new Markets(address(orbCoin));
    }
}
