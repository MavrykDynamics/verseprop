const { alice, bob, eve, mallory } = require("./scripts/sandbox/accounts");

module.exports = {
  confirmationPollingTimeoutSecond: 500000,

  // test config

  syncInterval: 0,
  confirmTimeout: 90000,

  // testnet deployment config

  // syncInterval: 5000,
  // confirmTimeout: 1800000,

  contracts : {
    mainnet : {
      superAdmin            : "",
      kyc                   : "",
      usdt                  : "", // usdt

      debtController        : ""
    },
    atlasnet : {
      superAdmin            : "KT1A8ee6yBDDfEtac5k798zCW5bBgmuw1AEe",
      kyc                   : "KT1RzBPUrktjuMGKYidfFC5t8BGJ8MSZaAp7",
      usdt                  : "KT1StUZzJ34MhSNjkQMSyvZVrR9ppkHMFdFf", // usdt

      debtController        : ""
    },
    local : {
      superAdmin            : "",
      kyc                   : "",
      usdt                  : "",

      debtController        : ""
    }
  },

  buildDir: "build",
  michelsonBuildDir : "contracts/compiled",
  migrationsDir: "migrations",
  michelsonBuildDir : "contracts/compiled",
  contractsDir: "contracts/main",
  contractLambdasDir: "contracts/partials/contractLambdas",
  ligoVersion: "0.62.0",
  network: "development",
  networks: {
    development: {
      rpc: "http://localhost:8732",
      network_id: "*",
      secretKey: bob.sk,
      port: 8732,
    },
    basenet: {
      rpc: "https://basenet-baking-full-node.mavryk.network",
      network_id: "*",
      secretKey: bob.sk,
      port: 443,
    },
    ghostnet: {
      rpc: "https://uoi3x99n7c.ghostnet.tezosrpc.midl.dev",
      port: 443,
      network_id: "*",
      secretKey: bob.sk,
    },
    jakartanet: {
      rpc: "https://jakartanet.ecadinfra.com",
      port: 443,
      network_id: "*",
      secretKey: bob.sk,
    },
    ithacanet: {
      rpc: "https://ithacanet.ecadinfra.com",
      port: 443,
      network_id: "*",
      secretKey: bob.sk,
    },
    hangzhounet: {
      rpc: "https://hangzhounet.api.tez.ie/",
      port: 443,
      network_id: "*",
      secretKey: bob.sk,
    },
    mainnet: {
      rpc: "https://mainnet.api.tez.ie",
      port: 443,
      network_id: "*",
      secretKey: bob.sk,
    },
  },
};