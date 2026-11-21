# FundMe

A simple crowdfunding contract built with Foundry. Users fund the contract with ETH, with a $5 USD minimum enforced via a live Chainlink price feed; the owner can withdraw the collected balance.

## Contracts

- `src/FundMe.sol` — accepts ETH funding above a USD-denominated minimum, tracks funders and their contributed amounts, and lets the owner withdraw.
- `src/PriceConverter.sol` — library that converts ETH amounts to their USD value using the Chainlink ETH/USD price feed.

## Stack

- [Foundry](https://getfoundry.sh/) for building, testing and deployment
- [Chainlink Price Feeds](https://docs.chain.link/data-feeds) for ETH/USD pricing

## Usage

```shell
forge install    # fetch dependencies
forge build
forge test
```

Tests mock the Chainlink price feed with `vm.mockCall`, so they run without needing a mainnet fork.

## Deploy

```shell
forge script script/DeployFundMe.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```
