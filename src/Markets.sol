pragma solidity ^0.8.10;
import "./OutcomeToken.sol";
import "./OrbCoin.sol";
import "./ZuniswapV2Pair.sol";

struct MarketInfo {
    string name;
    string description;
    address owner;
    address arbiter;
    address settlement;
    string[] outcomeNames;
    string[] outcomeSymbols;
    uint256 initialLiquidity;
    uint64 stopTime;
    uint64 settlementTime;
    uint64[] initialPrices;
}

struct Market {
    MarketInfo info;
    // NOTE: this could be read from pairs to preserve storage if required
    OutcomeToken[] outcomes;
    ZuniswapV2Pair[] pairs;
}

contract Markets {
    // TODO pick meaningful value
    uint256 public constant MIN_LIQUIDITY = 10_000;
    uint256 public constant BASE18 = 1 ether;
    // TODO pick better values experimentally
    uint256[] private multipliers = [70, 65, 60, 55, 50, 45, 40, 35, 30, 20];

    OrbCoin public orbCoin;
    Market[] public markets;

    constructor(address _orbCoin) {
        orbCoin = OrbCoin(_orbCoin);
    }

    function create(MarketInfo calldata info) public returns (uint256) {
        // prettier-ignore
        {
            require(
                bytes(info.name).length > 0,
                "empty name");
            require(
                info.outcomeNames.length == info.outcomeSymbols.length,
                "unconsistent lengths");
            require(
                info.outcomeNames.length >= 2,
                "not enough outcomes");
            require(
                info.initialLiquidity >= MIN_LIQUIDITY,
                "insufficient liquidity");
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
                "settlement time in the past");
        }

        OutcomeToken[] memory outcomes = new OutcomeToken[](
            info.outcomeNames.length
        );
        ZuniswapV2Pair[] memory pairs = new ZuniswapV2Pair[](
            info.outcomeNames.length
        );
        for (uint256 i = 0; i < info.outcomeNames.length; ++i) {
            outcomes[i] = new OutcomeToken(
                info.outcomeNames[i],
                info.outcomeSymbols[i]
            );
            pairs[i] = new ZuniswapV2Pair();
            pairs[i].initialize(address(outcomes[i]), address(orbCoin));
        }

        Market memory market = Market(info, outcomes, pairs);
        markets.push(market);
        uint256 marketID = markets.length;
        addLiquidity(marketID, info.initialLiquidity, info.owner);
        return marketID;
    }

    function addLiquidity(
        uint256 marketID,
        uint256 amount,
        address provider
    ) public {
        Market storage market = markets[marketID];
        uint256 multiplier = getMultiplier(marketID);
        uint256 sum = priceSum(marketID);

        // TODO check that the rounding is correct
        for (uint256 i = 0; i < market.outcomes.length; ++i) {
            uint256 priceFraction = price(marketID, i) / sum;
            ZuniswapV2Pair pair = market.pairs[i];
            orbCoin.mint(address(pair), (amount * multiplier) / BASE18);
            market.outcomes[i].mint(
                address(pair),
                (((amount * multiplier) / BASE18) * priceFraction) / BASE18
            );
            pair.mint(provider);
        }
    }

    function getMultiplier(uint256 marketID) internal view returns (uint256) {
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
        (uint112 outcomeAmount, uint112 stableAmount, ) = markets[marketID]
            .pairs[index]
            .getReserves();
        return (outcomeAmount * BASE18) / stableAmount;
    }

    function highestPrice(uint256 marketID) internal view returns (uint256) {
        uint256 length = markets[marketID].outcomes.length;
        uint256 max = 0;
        for (uint256 i = 0; i < length; ++i) {
            uint256 p = price(marketID, i);
            if (p > max) max = p;
        }
        return max;
    }

    function priceSum(uint256 marketID) internal view returns (uint256) {
        uint256 length = markets[marketID].outcomes.length;
        uint256 sum = 0;
        for (uint256 i = 0; i < length; ++i) {
            sum += price(marketID, i);
        }
        return sum;
    }
}
