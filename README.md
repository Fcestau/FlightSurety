# FlightSurety

FlightSurety is a sample application project for Udacity's Blockchain course.

## Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle), dApp scaffolding (using HTML, CSS and JS) and server app scaffolding.

To install, download or clone the repo, then:

`npm install`
`truffle compile`

## Contracts
  Network: Rinkeby
  flightSuretyApp: 0xeBfb14745000932D860D8E905c20292B12244B5B
  flightSuretyData: 0x51950BDfD78f8c37042eAB1fadaCFa7b0007E937
  ![deployedcontracts](https://user-images.githubusercontent.com/54293203/135788197-153139c1-4c52-475e-b2cb-26aeb700261f.png)


## Test results 

  ![test](https://user-images.githubusercontent.com/54293203/135788220-fa2768f1-6762-4e1d-b833-bc704001647e.png)

## Develop Client

To run truffle tests:

`truffle test ./test/flightSurety.js`
`truffle test ./test/oracles.js`

To use the dapp:

`truffle migrate`
`npm run dapp`

![frontend](https://user-images.githubusercontent.com/54293203/135788261-62dcd0dd-dc58-4836-b3e8-e1f4045d34d8.png)


To view dapp:

`http://localhost:8000`


## Develop Server

`npm run server`
`truffle test ./test/oracles.js`

## Deploy

To build dapp for prod:
`npm run dapp:prod`

Deploy the contents of the ./dapp folder

## Versions
`node - v14.17.3`
`truffle - v5.4.2`
`web3 - v1.4.0` 
`solidity - 0.4.25` 



