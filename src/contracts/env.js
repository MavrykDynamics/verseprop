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
      superAdmin            : "KT1F7rRJJaz5rdogQjdfrMi7sdCifby6b18k",
      kyc                   : "KT1SVEgxTrUK9N8cQBcwNLZkshMTbwcqARGB",
      usdt                  : "KT1StUZzJ34MhSNjkQMSyvZVrR9ppkHMFdFf", // usdt

      debtController        : "KT1EA31q1QxKULwsVcErJMWnCxEft52oft4W"
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
  ligoVersion: "0.60.0",
  network: "development",
  networks: {
    development: {
      rpc: "http://localhost:8732",
      network_id: "*",
      secretKey: bob.sk,
      port: 8732,
    },
    atlasnet: {
      rpc: "https://atlasnet.rpc.mavryk.network",
      network_id: "*",
      secretKey: bob.sk,
      port: 443,
    },
    basenet: {
      rpc: "https://basenet.rpc.mavryk.network",
      network_id: "*",
      secretKey: bob.sk,
      port: 443,
    },
    mainnet: {
      rpc: "https://mainnet.api.tez.ie",
      port: 443,
      network_id: "*",
      secretKey: bob.sk,
    },
  },
};