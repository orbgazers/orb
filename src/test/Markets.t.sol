pragma solidity ^0.8.10;
import "forge-std/Test.sol";
import "../Markets.sol";
import "../OrbCoin.sol";
import "../OutcomeToken.sol";

contract MarketsTest is Test {
    OrbCoin private orbCoin;
    MarketInfo private abBalanced;
    MarketInfo private abUnbalanced;
    uint256 private constant BASE18 = 1 ether;
    uint256 private constant INITIAL_LIQUIDITY = 10_000 * BASE18;
    Markets private markets;

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

        MarketInfo memory abBase = MarketInfo({
            name: "AB",
            description: "it's A or B, baby",
            owner: address(this),
            arbiter: address(this),
            settlement: address(this), // TODO
            id: 0,
            numOutcomes: 2,
            outcomeNames: names,
            outcomeSymbols: symbols,
            initialLiquidity: INITIAL_LIQUIDITY,
            stopTime: uint64(block.timestamp + 7_000),
            settlementTime: uint64(block.timestamp + 7_000),
            initialPrices: prices
        });

        abBalanced = abBase;

        uint64[] memory prices2 = new uint64[](2);
        prices2[0] = uint64((BASE18 * 9) / 10);
        prices2[1] = uint64(BASE18 / 10);
        abUnbalanced = abBase;
        abUnbalanced.initialPrices = prices2;

        markets = new Markets(address(orbCoin));
        orbCoin.setOwner(address(markets));
    }

    function testCreateBalanced() public {
        uint256 id = markets.create(abBalanced);
        assertEq(id, 0);
        assertTrue(markets.pairss(id, 0) != markets.pairss(id, 1));
        verifyPair(id, 0);
        verifyPair(id, 1);
    }

    function testCreateUnbalanced() public {
        //        uint256 id = markets.create(abUnbalanced);
        //        assertEq(id, 0);
        //        assertTrue(markets.pairss(id, 0) != markets.pairss(id, 1));
        //        verifyPair(id, 0);
        //        verifyPair(id, 1);
    }

    function verifyPair(uint256 id, uint256 i) internal {
        assertEq(markets.price(id, i), BASE18 / 2);

        ZuniswapV2Pair pair = markets.pairss(id, i);
        OutcomeToken outcome = markets.outcomees(id, i);

        assertEq(pair.token0(), address(outcome));
        assertEq(pair.token1(), address(orbCoin));
        // NOTE: 1000 is the Uniswap minimum liquidity
        assertEq(pair.balanceOf(address(this)), pair.totalSupply() - 1000);

        // NOTE: 10k liquidity → 2x multiplier, each pool has 10k outcome tokens and 20k orb coins
        assertEq(outcome.totalSupply(), INITIAL_LIQUIDITY * 2);
        assertEq(outcome.balanceOf(address(pair)), INITIAL_LIQUIDITY * 2);
        assertEq(orbCoin.balanceOf(address(pair)), INITIAL_LIQUIDITY);
    }
}
