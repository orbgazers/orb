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
        assertEq(id, markets.markets(id).id);
        assertTrue(markets.pairss(id, 0) != markets.pairss(id, 1));
        verifyPair(id, 0);
        verifyPair(id, 1);
    }

    function testCreateUnbalanced() public {
        uint256 id = markets.create(abUnbalanced);
        assertEq(id, 0);
        assertEq(id, markets.markets(id).id);
        assertTrue(markets.pairss(id, 0) != markets.pairss(id, 1));
        verifyPair(id, 0);
        verifyPair(id, 1);
    }

    function verifyPair(uint256 id, uint256 i) internal {
        MarketInfo memory info = markets.markets(id);

        ZuniswapV2Pair pair = markets.pairss(id, i);
        OutcomeToken outcome = markets.outcomees(id, i);

        assertEq(pair.token0(), address(outcome));
        assertEq(pair.token1(), address(orbCoin));

        // NOTE: 1000 is the Uniswap minimum liquidity
        assertEq(pair.balanceOf(address(this)), pair.totalSupply() - 1000);

        uint256 price = markets.price(id, i);
        assertEq(price, info.initialPrices[i]);

        // two scenarios: balanced (50/50), unbalanced (10/90)
        bool balanced = info.initialPrices[i] == BASE18 / 2;

        uint256 multiplier = markets.getMultiplier(id);
        assertEq(multiplier, balanced ? (BASE18 * 2) : (BASE18 * 100) / 70);

        // E.G. 50/50 pool, 10k liquidity, and 2x multiplier → 20k bundles
        //      20k outcome tokens (0.5$ each) and 10k ORB per pool
        //      each pool is worth 20k$
        assertEq(
            outcome.totalSupply(),
            (INITIAL_LIQUIDITY * multiplier) / BASE18
        );
        assertEq(
            outcome.balanceOf(address(pair)),
            (INITIAL_LIQUIDITY * multiplier) / BASE18
        );
        assertEq(
            orbCoin.balanceOf(address(pair)),
            (((INITIAL_LIQUIDITY * multiplier) / BASE18) * price) / BASE18
        );
    }
}
