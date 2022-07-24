pragma solidity ^0.8.10;
import "./OutcomeToken.sol";
import "./OrbCoin.sol";
import "./LPToken.sol";
import "./ZuniswapV2Pair.sol";
import "./ZuniswapV2Router.sol";
import {console2} from "forge-std/Test.sol";

struct Market {
    MarketInfo info;
}

struct MarketInfo {
    // slot 1
    address owner;
    uint64 stopTime;
    // slot 2
    address arbiter;
    uint64 settlementTime;
    // slot 3
    address settlement;
    uint64 id;
    uint8 numOutcomes;
    uint256 initialLiquidity;
    string name;
    string description;
    string[] outcomeNames;
    string[] outcomeSymbols;
    uint64[] initialPrices;
}

contract Markets {
    // TODO pick meaningful value
    uint256 public constant MIN_LIQUIDITY = 10_000;
    uint256 public constant BASE18 = 1 ether;
    // TODO pick better values experimentally
    uint256[] private multipliers = [
        (BASE18 * 100) / 20,
        (BASE18 * 100) / 30,
        (BASE18 * 100) / 35,
        (BASE18 * 100) / 40,
        (BASE18 * 100) / 45,
        (BASE18 * 100) / 50,
        (BASE18 * 100) / 55,
        (BASE18 * 100) / 60,
        (BASE18 * 100) / 65,
        (BASE18 * 100) / 70
    ];

    OrbCoin public orbCoin;
    IERC20 public backingCoin;
    Market[] public markets;
    mapping(uint256 => OutcomeToken[]) public outcomes;
    mapping(uint256 => ZuniswapV2Pair[]) public pairs;
    mapping(uint256 => LPToken) public lpTokens;
    mapping(uint256 => uint256) public backing;

    constructor(address _orbCoin, address _backingCoin) {
        orbCoin = OrbCoin(_orbCoin);
        backingCoin = IERC20(_backingCoin);
    }

    function numMarkets() external view returns (uint256) {
        return markets.length;
    }

    function getMarketList() external view returns (Market[] memory) {
        Market[] memory _markets = markets;
        return _markets;
    }

    function create(MarketInfo calldata info) public returns (uint256) {
        // prettier-ignore
        {
            require(
                bytes(info.name).length > 0,
                "empty name");
            require(
                info.numOutcomes >= 2,
                "not enough outcomes");
            require(
                info.numOutcomes == info.outcomeNames.length,
                "unconsistent lengths");
            require(
                info.numOutcomes == info.outcomeSymbols.length,
                "unconsistent lengths");
            require(
                info.numOutcomes == info.initialPrices.length,
                "unconsistent lengths");
            require(
                info.initialLiquidity >= MIN_LIQUIDITY,
                "insufficient liquidity");
            require(
                info.owner != address(0),
                "0 address owner");
            require(
                info.arbiter != address(0),
                "0 address arbiter");
            require(
                info.settlement != address(0),
                "0 address settlement");
            require(
                info.stopTime > block.timestamp,
                "stop time in the past");
            require(
                info.settlementTime >= info.stopTime,
                "settlement time before stop time");
        }

        uint64 id = uint64(markets.length);
        lpTokens[id] = new LPToken(id);
        {
            uint256 sum = 0;
            OutcomeToken[] storage _outcomes = outcomes[id];
            ZuniswapV2Pair[] storage _pairs = pairs[id];
            for (uint256 i = 0; i < info.outcomeNames.length; ++i) {
                _outcomes.push(
                    new OutcomeToken(
                        info.outcomeNames[i],
                        info.outcomeSymbols[i]
                    )
                );
                _pairs.push(new ZuniswapV2Pair());
                _pairs[i].initialize(address(_outcomes[i]), address(orbCoin));
                sum += info.initialPrices[i];
            }
            require(sum == BASE18, "price sum is not $1");
        }

        markets.push(Market(info));
        markets[id].info.id = id;
        addInitialLiquidity(
            id,
            info.initialLiquidity,
            info.owner,
            info.initialPrices
        );
        return id;
    }

    function addInitialLiquidity(
        uint256 marketID,
        uint256 amount,
        address provider,
        uint64[] calldata initialPrices
    ) internal {
        uint256 multiplier;
        {
            uint256 max = 0;
            for (uint256 i = 0; i < initialPrices.length; ++i) {
                uint256 p = initialPrices[i];
                if (p > max) max = p;
            }
            multiplier = multipliers[(max * 10) / BASE18];
        }

        // TODO check that the rounding is correct
        OutcomeToken[] storage _outcomes = outcomes[marketID];
        ZuniswapV2Pair[] storage _pairs = pairs[marketID];
        for (uint256 i = 0; i < _outcomes.length; ++i) {
            mintForOutcome(
                amount,
                multiplier,
                initialPrices[i],
                _outcomes[i],
                _pairs[i]
            );
        }
        backingCoin.transferFrom(provider, address(this), amount);
        backing[marketID] += amount;
        // initially: 1 LP token per 1$ of backing provided
        lpTokens[marketID].mint(provider, amount);
    }

    function mintForOutcome(
        uint256 amount,
        uint256 multiplier,
        uint256 priceFraction,
        OutcomeToken outcome,
        ZuniswapV2Pair pair
    ) internal {
        uint256 mintAmount = (amount * multiplier) / BASE18;
        outcome.mint(address(pair), mintAmount);
        mintAmount = (mintAmount * priceFraction) / BASE18;
        orbCoin.mint(address(pair), mintAmount);
        pair.mint(address(this));
    }

    function addLiquidity(
        uint256 marketID,
        uint256 amount,
        address provider
    ) external {
        uint256 multiplier = getMultiplier(marketID);
        uint256 sum = priceSum(marketID);

        // TODO check that the rounding is correct
        OutcomeToken[] storage _outcomes = outcomes[marketID];
        ZuniswapV2Pair[] storage _pairs = pairs[marketID];
        for (uint256 i = 0; i < _outcomes.length; ++i) {
            uint256 priceFraction = (price(marketID, i) * BASE18) / sum;
            mintForOutcome(
                amount,
                multiplier,
                priceFraction,
                _outcomes[i],
                _pairs[i]
            );
        }
        backingCoin.transferFrom(provider, address(this), amount);
        uint256 oldBacking = backing[marketID];
        backing[marketID] += amount;
        LPToken lpToken = lpTokens[marketID];
        // Mint proportionally to backing (e.g. if doubling total backing, provider will end up
        // owning half the total supply of the LP token).
        lpToken.mint(
            provider,
            (((amount * BASE18) / oldBacking) * lpToken.totalSupply()) / BASE18
        );
    }

    function getMultiplier(uint256 marketID) public view returns (uint256) {
        uint256 highest = highestPrice(marketID);
        // normalize to [0, 9]
        highest = (highest * 10) / BASE18;
        // in case people are irrational and push the price past 1$
        if (highest > 9) highest = 9;
        return multipliers[highest];
    }

    function price(uint256 marketID, uint256 index)
        public
        view
        returns (uint256)
    {
        (uint112 outcomeAmount, uint112 stableAmount, ) = pairs[marketID][index]
            .getReserves();

        return (stableAmount * BASE18) / outcomeAmount;
    }

    function highestPrice(uint256 marketID) internal view returns (uint256) {
        uint256 length = outcomes[marketID].length;
        uint256 max = 0;
        for (uint256 i = 0; i < length; ++i) {
            uint256 p = price(marketID, i);
            if (p > max) max = p;
        }
        return max;
    }

    function priceSum(uint256 marketID) internal view returns (uint256) {
        uint256 length = outcomes[marketID].length;
        uint256 sum = 0;
        for (uint256 i = 0; i < length; ++i) {
            sum += price(marketID, i);
        }
        return sum;
    }

    function buy(
        uint256 marketID,
        uint256 index,
        uint256 amountIn,
        uint256 amountOutMin,
        address buyer
    ) public returns (uint256) {
        ZuniswapV2Pair pair = pairs[marketID][index];
        orbCoin.mint(address(this), amountIn);
        (uint256 rOutcome, uint256 rOrb, ) = pair.getReserves();
        uint256 amountOut = ZuniswapV2Library.getAmountOut(
            amountIn,
            rOrb,
            rOutcome
        );
        require(amountOut >= amountOutMin, "excessive slippage");
        orbCoin.transfer(address(pair), amountIn);
        pair.swap(amountOut, 0, buyer, "");
        backingCoin.transferFrom(buyer, address(this), amountIn);
        return amountOut;
    }

    function sell(
        uint256 marketID,
        uint256 index,
        uint256 amountIn,
        uint256 amountOutMin,
        address seller
    ) public returns (uint256) {
        ZuniswapV2Pair pair = pairs[marketID][index];
        OutcomeToken outcome = outcomes[marketID][index];
        (uint256 rOutcome, uint256 rOrb, ) = pair.getReserves();
        uint256 amountOut = ZuniswapV2Library.getAmountOut(
            amountIn,
            rOutcome,
            rOrb
        );
        require(amountOut >= amountOutMin, "excessive slippage");
        outcome.transferFrom(seller, address(pair), amountIn);
        pair.swap(0, amountOut, address(this), "");
        orbCoin.burn(address(this), amountOut);
        backingCoin.transfer(seller, amountOut);
        return amountOut;
    }
}
