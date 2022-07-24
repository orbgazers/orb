pragma solidity ^0.8.10;
import "forge-std/Test.sol";
import "../ERC20Mintable.sol";
import "../Markets.sol";
import "../OrbCoin.sol";
import "../OutcomeToken.sol";
import "../ZuniswapV2Factory.sol";
import "../ZuniswapV2Router.sol";

contract MarketsTest is Test {
    OrbCoin private orbCoin;
    ERC20Mintable private backingCoin;
    address private factory;
    address private router;
    MarketInfo private abBalanced;
    MarketInfo private abUnbalanced;
    uint256 private constant BASE18 = 1 ether;
    uint256 private constant INITIAL_LIQUIDITY = 10_000 * BASE18;
    Markets private markets;

    function setUp() public {
        orbCoin = new OrbCoin();
        backingCoin = new ERC20Mintable("Backing", "BAK");
        factory = address(new ZuniswapV2Factory());
        router = address(new ZuniswapV2Router(factory));

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

        markets = new Markets(address(orbCoin), address(backingCoin));
        orbCoin.setOwner(address(markets));
    }

    function createMarket(MarketInfo storage info, uint256 mint)
        internal
        returns (uint256 id)
    {
        backingCoin.mint(address(this), mint);
        backingCoin.approve(address(markets), mint);
        id = markets.create(info);
    }

    function testCreateBalanced() public {
        createTestForInfo(abBalanced);
    }

    function testCreateUnbalanced() public {
        createTestForInfo(abUnbalanced);
    }

    function createTestForInfo(MarketInfo storage info) internal {
        uint256 id = createMarket(info, INITIAL_LIQUIDITY);
        assertEq(id, 0);
        assertEq(backingCoin.balanceOf(address(this)), 0);
        assertEq(backingCoin.balanceOf(address(markets)), INITIAL_LIQUIDITY);
        assertEq(
            markets.lpTokens(id).balanceOf(address(this)),
            INITIAL_LIQUIDITY
        );
        assertEq(id, markets.markets(id).id);
        assertTrue(markets.pairs(id, 0) != markets.pairs(id, 1));
        verifyPair(id, 0, INITIAL_LIQUIDITY, info.initialPrices[0]);
        verifyPair(id, 1, INITIAL_LIQUIDITY, info.initialPrices[1]);
    }

    function verifyPair(
        uint256 id,
        uint256 i,
        uint256 liquidity,
        uint256 expectedPrice
    ) internal {
        MarketInfo memory info = markets.markets(id);

        ZuniswapV2Pair pair = markets.pairs(id, i);
        OutcomeToken outcome = markets.outcomes(id, i);

        assertEq(pair.token0(), address(outcome), "bad token 0");
        assertEq(pair.token1(), address(orbCoin), "bad token 1");

        // NOTE: 1000 is the Uniswap minimum liquidity
        assertEq(
            pair.balanceOf(address(markets)),
            pair.totalSupply() - 1000,
            "bad pair balance"
        );

        uint256 price = markets.price(id, i);
        assertEq(price, expectedPrice, "bad price");

        // two scenarios: balanced (50/50), unbalanced (10/90)
        bool balanced = info.initialPrices[i] == BASE18 / 2;

        uint256 multiplier = markets.getMultiplier(id);
        assertEq(
            multiplier,
            balanced ? (BASE18 * 2) : (BASE18 * 100) / 70,
            "bad multiplier"
        );

        // E.G. 50/50 pool, 10k liquidity, and 2x multiplier → 20k bundles
        //      20k outcome tokens (0.5$ each) and 10k ORB per pool
        //      each pool is worth 20k$
        assertEq(
            outcome.totalSupply(),
            (liquidity * multiplier) / BASE18,
            "bad outcome supply"
        );
        assertEq(
            outcome.balanceOf(address(pair)),
            (liquidity * multiplier) / BASE18,
            "bad outcome balance"
        );
        assertEq(
            orbCoin.balanceOf(address(pair)),
            (((liquidity * multiplier) / BASE18) * price) / BASE18,
            "bad orb balance"
        );
    }

    function testAddLiquidityBalanced() public {
        addLiquidityTestForInfo(abBalanced);
    }

    function testAddLiquidityUnbalanced() public {
        addLiquidityTestForInfo(abUnbalanced);
    }

    function addLiquidityTestForInfo(MarketInfo storage info) internal {
        uint256 id = createMarket(info, INITIAL_LIQUIDITY * 2);
        markets.addLiquidity(id, INITIAL_LIQUIDITY, address(this));
        assertEq(backingCoin.balanceOf(address(this)), 0);
        assertEq(
            backingCoin.balanceOf(address(markets)),
            INITIAL_LIQUIDITY * 2
        );
        assertEq(
            markets.lpTokens(id).balanceOf(address(this)),
            INITIAL_LIQUIDITY * 2
        );
        verifyPair(id, 0, INITIAL_LIQUIDITY * 2, info.initialPrices[0]);
        verifyPair(id, 1, INITIAL_LIQUIDITY * 2, info.initialPrices[1]);
    }

    function testBuyBalanced() public {
        buyTest(abBalanced, 0);
        buyTest(abBalanced, 1);
    }

    function testBuyUnbalanced() public {
        buyTest(abUnbalanced, 0);
        buyTest(abUnbalanced, 1);
    }

    function buyTest(MarketInfo storage info, uint256 index) internal {
        uint256 id = createMarket(info, INITIAL_LIQUIDITY);
        uint256 amount = 1000 * BASE18;
        backingCoin.mint(address(this), amount);
        backingCoin.approve(address(markets), amount);
        OutcomeToken outcome = markets.outcomes(id, index);

        // ignore slippage for now
        markets.buy(id, index, amount, 0, address(this));
        assertEq(backingCoin.balanceOf(address(this)), 0);

        // balanced (50/50) case: each pool start with 20k outcome / 10k ORB
        // unbalanced (90/10): each pool starts with ~14.3k outcome / ~12.9k/1.4k ORB
        if (info.initialPrices[index] == BASE18 / 2) {
            assertEq(
                outcome.balanceOf(address(this)) / BASE18,
                1813,
                "bad 50/50 buy balance"
            );
        } else if (info.initialPrices[index] == (BASE18 * 9) / 10) {
            // unbalanced 90/10: 90% side
            assertEq(
                outcome.balanceOf(address(this)) / BASE18,
                1028,
                "bad 90 buy balance"
            );
        } else {
            // unbalanced 90/10: 10% side
            assertEq(
                outcome.balanceOf(address(this)) / BASE18,
                5871,
                "bad 10 buy balance"
            );
        }
    }

    function testSellBalanced() public {
        sellTest(abBalanced, 0);
        sellTest(abBalanced, 1);
    }

    function testSellUnbalanced() public {
        sellTest(abUnbalanced, 0);
        sellTest(abUnbalanced, 1);
    }

    function sellTest(MarketInfo storage info, uint256 index) internal {
        uint256 id = createMarket(info, INITIAL_LIQUIDITY);
        uint256 amount = 1000 * BASE18;
        OutcomeToken outcome = markets.outcomes(id, index);
        vm.prank(address(markets));
        outcome.mint(address(this), amount);
        outcome.approve(address(markets), amount);

        // ignore slippage for now
        markets.sell(id, index, amount, 0, address(this));
        assertEq(outcome.balanceOf(address(this)), 0);

        uint256 balance = backingCoin.balanceOf(address(this));

        // balanced (50/50) case: each pool start with 20k outcome / 10k ORB
        // unbalanced (90/10): each pool starts with ~14.3k outcome / ~12.9k/1.4k ORB
        if (info.initialPrices[index] == BASE18 / 2) {
            assertEq(balance / BASE18, 474, "bad 50/50 sell balance");
        } else if (info.initialPrices[index] == (BASE18 * 9) / 10) {
            // unbalanced 90/10: 90% side
            assertEq(balance / BASE18, 838, "bad 90 sell balance");
        } else {
            // unbalanced 90/10: 10% side
            assertEq(balance / BASE18, 93, "bad 10 sell balance");
        }
        backingCoin.burn(address(this), balance);
    }

    // TODO:
    // if not enough balance, transferFrom (on ERC20Mintable) fails with arithmetic over/underflow
}
