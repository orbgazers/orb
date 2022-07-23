pragma solidity ^0.8.10;
import "forge-std/Test.sol";
import "../Markets.sol";
import "../OrbCoin.sol";
import "../OutcomeToken.sol";

contract MarketsTest is Test {
    OrbCoin private orbCoin;
    MarketInfo private ab;
    uint256 private constant BASE18 = 1 ether;
    uint256 private constant INITIAL_LIQUIDITY = 10_000;
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

        ab = MarketInfo({
            name: "AB",
            description: "it's A or B, baby",
            owner: address(this),
            arbiter: address(this),
            settlement: address(this), // TODO
            id: 0,
            numOutcomes: 2,
            outcomeNames: names,
            outcomeSymbols: symbols,
            initialLiquidity: 10_000,
            stopTime: uint64(block.timestamp + 7_000),
            settlementTime: uint64(block.timestamp + 7_000),
            initialPrices: prices
        });

        markets = new Markets(address(orbCoin));
        orbCoin.setOwner(address(markets));
    }

    function testCreate() public {
        uint256 id = markets.create(ab);
        assertEq(id, 0);
        assertTrue(markets.pairss(id, 0) != markets.pairss(id, 1));

        assertEq(markets.price(id, 0), BASE18 / 2);
        assertEq(markets.price(id, 1), BASE18 / 2);

        address pair0 = address(markets.pairss(id, 0));
        address pair1 = address(markets.pairss(id, 1));
        OutcomeToken outcome0 = markets.outcomees(id, 0);
        OutcomeToken outcome1 = markets.outcomees(id, 1);

        assertEq(ZuniswapV2Pair(pair0).token0(), address(outcome0));
        assertEq(ZuniswapV2Pair(pair0).token1(), address(orbCoin));
        assertEq(ZuniswapV2Pair(pair1).token0(), address(outcome1));
        assertEq(ZuniswapV2Pair(pair1).token1(), address(orbCoin));

        // NOTE: 1000 is the Zuniswap minimum liquidity
        assertEq(ZuniswapV2Pair(pair0).balanceOf(address(this)), ZuniswapV2Pair(pair0).totalSupply() - 1000);
        assertEq(ZuniswapV2Pair(pair1).balanceOf(address(this)), ZuniswapV2Pair(pair1).totalSupply() - 1000);

        assertEq(markets.outcomees(id, 0).totalSupply(), INITIAL_LIQUIDITY);
        assertEq(markets.outcomees(id, 1).totalSupply(), INITIAL_LIQUIDITY);
        assertEq(markets.outcomees(id, 0).balanceOf(pair0), INITIAL_LIQUIDITY);
        assertEq(markets.outcomees(id, 1).balanceOf(pair1), INITIAL_LIQUIDITY);
        // TODO both fail: actual balance 20k, expected 5000
        assertEq(orbCoin.balanceOf(pair0), INITIAL_LIQUIDITY / 2);
        assertEq(orbCoin.balanceOf(pair1), INITIAL_LIQUIDITY / 2);
    }

    function verifyPair(uint256 id, uint256 i) internal {
        assertEq(markets.price(id, i), BASE18 / 2);

        ZuniswapV2Pair pair = markets.pairss(id, i);
        OutcomeToken outcome = markets.outcomees(id, i);

        assertEq(pair.token0(), address(outcome));
        assertEq(pair.token1(), address(orbCoin));
        // NOTE: 1000 is the Uniswap minimum liquidity
        assertEq(pair.balanceOf(address(this)), pair.totalSupply() - 1000);
        assertEq(outcome.totalSupply(), INITIAL_LIQUIDITY);
        assertEq(outcome.balanceOf(address(pair)), INITIAL_LIQUIDITY);
        assertEq(orbCoin.balanceOf(address(pair)), INITIAL_LIQUIDITY / 2);
    }
}
