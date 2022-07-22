# The Pondering Orb

A market for predictions, bets, options — and all matters of promises.

## General Idea

The Pondering Orb is a prediction market platform. Many markets exist on the
platform.

Each market defines a precise question and a predefined set of answers (we'll
sometimes refer to them as *outcomes*). A token is associated with every answer.

In simple cases, the set of answer is exhaustive, such that a winning answer can
always be picked.

The market has one liquidity pool per answer token, in which the answer token
trades against a stablecoin. This is a protocol-specific stablecoin, for reasons
that will become apparent later.

For now you can think of these liquidity pools as simple Uniswap V2 pools. More
details will be given later.

The price of every answer token is in the `[$0, $1]` range. The price of all
answer tokens must sum to $1.

Because every trade in a liquidity pool shifts the price in that pool, the pools
need to be periodically rebalanced to restore the invariant.

Each market has a closing time, at which answer tokens stop trading; as well as
a settlement time, at which the redemption of value each answer token is
decided. They must still sum to $1.

Settlement happens by calling the settlement contract (anybody can trigger this
call at settlement time or after). Once settlement has happened, users cand
redeem their answer tokens for stablecoins.

Each market has an arbiter, a uniquely identified individual or group
responsible for the subjective part of the settlement decision (if any — the
settlement could also be fully automated and based on on-chain data). An
arbiter's decision history is tracked on-chain and acts as a form of reputation.

Each market also has a creator who defines the parameters of the market. The
creator and the arbiter can be the same person. If the arbiter is different from
the creator, he must explicitly accept the responsability of arbitrating the
market.

(Future work: think of good, non-griefable, mechanisms to express
dissatisfaction with an arbiter's decision.)

Simple markets are "binary markets": the winning answer token will be worth $1,
while the other tokens will be worth 0. A good example of this would be betting
on the outcome of sport tournaments, or answering yes/no questions.

More complex *pro rata* markets are possible. For instance: a market on the
price of ETH in the `[$0, $2000]` range, with two tokens (LONG and SHORT). The
redemption value for the LONG token will be worth `max($1, eth_price / 2000)`,
while the SHORT token will be worth `$1 - long_price`. The ETH price is taken at
settlement time. Note that the value of LONG and SHORT sums to exactly $1.

This market can be fully settled using on-chain price oracles, and so its
closing time can in theory be the same as its closing time. In practice, the
market's creator may want to define the closing time as being earlier than the
settlement time, in order to secure more profit for the liquidity providers.

We have some good use cases for both binary and pro-rata markets, which we'll
give later. But for now lets' focus on the innovative AMM mechanics.

## Market Liquidity

In our initial implementation, each answer pool (where an answer token trades
against a stablecoin) is a regular Uniswap V2 pool.

Given this, a liquidity providers needs to acquire answer tokens and stablecoins
and add liquidity into each answer pool.

A bundle containing one of each answer token can be acquired for $1, ensuring
each answer token is fully backed by its redemption value at settlement time.
There is no way for regular users to purchase a bundle, it is only possible when
supplying liquidity.

In the first version of the protocol, liquidity providers won't be able to
withdraw their liquidity before settlement. In the future we can investigate
whether we can enable this while keeping markets orderly.

Whenever a user trades with an answer pool, the price of the corresponding
answer token moves. This creates an arbitrage opportunity:

- In case of a purchase (answer token price goes up): If it was possible for
  anyone to purchase bundles, they could purchase a bundle for `$1`, and sell
  its components for more than `$1` in total.
- In case of a sale (answer token price goes down): Anybody can snag one of each
  token for less than `$1` in total, and wait until settlement to redeem them
  for exactly `$1`. We could also imagine it could be possible to recombine one
  of each answer token into a bundle and redeem it instantly for `$1`.

The protocol performs this arbitrage on behalf of the liquidity providers. It
acts a little bit like a flashloan: in the price increase case, we borrow to
purchase bundle, sell at a profit and repay; in the price decrease case, we
borrow to purchase answer tokens, reconstruct and redeem a bundle at a profit,
and repay. (Not having to pay interest on this flashloan is one of the reasons
why it's interesting for the protocol to have its own stablecoin.)

Also note that these arbitrages change nothing about the backing of the answer
tokens: each complete set of answer tokens will still be redeemable at `$1` at
settlement time. The arbitrages do change the circulating supply of answer
tokens however.

Note in passing that every answer token (in a given market) has the same
circulating supply (if you include the tokens in the liquidity pool itself).

### LP Profits and Losses

The main issue with existing, fully-on-chain, prediction market LP is that the
proposition value for liquidity providers is not amazing.

Let's take a simple market as an example, and look at the worst possible case
for LPs. This will be a binary market with two choices, for instance: "Who will
win the 2022 rugby world cup: France or South Africa?". Our two tokens will be
FR and SA. Initial prices will be $0.50 for each of those. Imagine the initial
liquidity is 10,000 tokens of each.

TODO initial prices?

The worst possible case is that, immediately after the market goes live, it
becomes apparent that one of the two teams (say France) has an overwhelming
chance to win.

In this case, betters would buy up as much FR tokens as possible.

The most tokens a buyer could (rationally) buy in a single trade is 2929.

The reason is the pool (UniswapV2-style) `x*y=z` or `a*s=z` curve, where `a` is
the amount of answer tokens and `s` is the amount of stables. The price of the
answer token in stable is given by `s/a`.

The answer token is worth $1 when `a = s = sqrt(z)`. In our example that's `a =
s = 7071`, hence at most `10,000 - 7071 = 2929` can be purchased from of the
pool without exceeding the $1 price tag.

These tokens are purchased for $2071 (`7071 - 5000`), at an average price of
`2071 / 2929 = $0.707`.

However, this trade puts the answer token prices out of whack, since we now have
FR = $1 and SA = $0.5, for a total of $1.5.

The protocol will thus arbitrage to bring the total price back to $1. For this,
it needs to mint and sell an amount `da` of answer tokens into both the FR and
SA pools.

`da` can be found analytically in this case, but doing so requires solving a
quartic equation, which is [not the easiest thing to program][quartic]. It's
even harder (higher degree equation) when there are more than two answers.
Instead, we'll opt to perform a bisection to find a sufficiently close
approximation.

[quartic]: https://en.wikipedia.org/wiki/Quartic_equation#Solving_a_quartic_equation

(I'm not a mathematician, and in this case we know that there should be a single
solution to our system of equation, so maybe there is a relatively simple way to
find `da`.)

Doing some hand calculations in this specific case lets us find that after
selling 1750 FR and SA tokens in their respective pools, the prices drop to
approximately $0.64 and $0.36 (respectively), restoring our invariant.

These 1750 token pairs are sold for a total of $2148, netting the pool a profit
of `2148 - 1750 = $398`.

Meanwhile, the pools now hold 8821 FR token and 11750 SA tokens, for asset value
of `2 * (8821 * 0.64 + 11750 * 0.36) = $19750.88`. This is a loss of
approximately $250, which the arbitrage profits more than compensate.

Something that should be apparent in this scenario is that the buyer made a very
bad operation, because he purchased the tokens at an average price of $0.707,
higher than the post-arbitrage price of $0.64.

A more realistic strategy would have been to split the trade into multiple
operations. If the buyer had split his purchases into three buys of (1000, 1000,
929), he would have obtained a much more advantageous average price of $0.61.

Conversely, the pool's arbitrage profits would have decreased to a mere $113,
which now doesn't suffice the cover the $250 pool value loss.

That being said, it seems to be a property of the system, when using constant
product curves, that it impossible for a buyer to obtain an average purchase
price smaller than the price after the arbitrage has been applied!

I have no mathematical proof for this, but here is some intuition. As answer
token reserves decreases, the price slope gets steeper — hence price accelerates
up as reserve decrease. Therefore, the sale of answer tokens from arbitrage
seems to decrease price in a way that is super-proportional to the price
increase caused by the original purchase. In other words, the arbitrage sale
travels backward along the steepest section of the part of the curve that the
initial purchase travelled in the reverse direction.

It also seems true that, if there were no transaction fees, the optimal strategy
would be to split every purchases into infinitely small chunks.

This seems rather undesirable, and can be mitigated in multiple ways. Here are
two ideas, that can even be combined:

1. Charge a flat transaction fee. Splitting is still interesting, but only up to
   a limit that depends on the amount of the transaction fee (+ blockchain-level
   transaction fees).
2. Don't automatically arbitrage after each trade. Instead, only arbitrage once
   the sum of the price of all answer tokens has reached some threshold above or
   under $1.

Idea (2) negates the benefits of splitting trades. However, it adds the risk of
organic trading taking away arbitrage opportunities by cancelling other trades.
These cancelling trades come in two forms:

1. Purchases and sales in the same pool. These are not too bad, because they do
   not worsen the total asset value of the answer pools.
2. Purchase in a pool and sale in the other pool. This is more annoying, as it
   does reduce the total asset value of the answer pools, but without the
   opportunity for arbitrage. It's also tempting from the point of view of the
   sellers: if they see an arbitrage coming because of rising FR value, they'd
   rather frontrun it, sell their SA tokens for a value X higher than the
   expected value post-arbitrage (at which point they can repurchase the SA
   tokens on the cheap, assuming they were not the only token holder). There is
   however an execution risk: the sale delays the arbitrage, which might never
   come if the price of the answer tokens starts trading in the opposite
   direction (FR down and/or SA up).

We implement both mechanism in the orb. For each market, its creator can set the
amount of the flat fee (can be 0) and the arbitrage threshold (can be 0, in wich
case every trades gets arbitraged).

TODO: worst case scenario

### Capital Efficiency
