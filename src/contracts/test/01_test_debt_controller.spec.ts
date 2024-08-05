import { MichelsonMap } from "@taquito/michelson-encoder"
import { Utils } from './helpers/Utils'
import { char2Bytes } from '@taquito/utils'
import { RpcClient } from '@taquito/rpc';
import env from '../env'

const chai = require('chai')
const assert = require('chai').assert
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
chai.should()

// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import contractDeployments from './contractDeployments.json'

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { bob, alice, eve, mallory } from '../scripts/sandbox/accounts'
import { 
    signerFactory, 
    wait,
    getStorageMapValue,
    makeSnapshotTimestamp,
    makeTimestamp
} from './helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Notes
// ------------------------------------------------------------------------------

// RWA Tests 

// ------------------------------------------------------------------------------
// Contract Tests
// ------------------------------------------------------------------------------

describe('Test: Debt Controller', async () => {

    // default
    let utils: Utils
    let tezos
    let client

    // misc defaults
    let token_id 
    let tokenAmount
    let operator
    let operatorKey

    // contract instances 
    let superAdminAddress, superAdminInstance, superAdminStorage
    let rwaTokenAddress, rwaTokenInstance, rwaTokenStorage
    let kycAddress, kycInstance, kycStorage
    let debtControllerAddress, debtControllerInstance, debtControllerStorage

    // user accounts
    let user, userSk
    let admin, adminSk
    let sender, receiver

    // contract map value
    let storageMap
    let contractMapKey
    let initialContractMapValue
    let updatedContractMapValue

    // operations
    let transferOperation, kycOperation
    let superAdminOperation
    let updateOperatorsOperation
    let removeOperatorsOperation
    let setAdminOperation
    let resetAdminOperation
    
    before('setup', async () => {
        
        utils = new Utils()
        await utils.init(bob.sk)
        tezos = utils.tezos;
        client = new RpcClient(env.networks.development.rpc);

        admin           = eve.pkh 
        adminSk         = eve.sk 

        superAdminAddress   = contractDeployments.superAdmin.address
        superAdminInstance  = await utils.tezos.contract.at(superAdminAddress)
        superAdminStorage   = await superAdminInstance.storage()

        rwaTokenAddress     = contractDeployments.rwaTokenNonFungible.address;
        rwaTokenInstance    = await utils.tezos.contract.at(rwaTokenAddress)
        rwaTokenStorage     = await rwaTokenInstance.storage()

        kycAddress          = contractDeployments.kyc.address;
        kycInstance         = await utils.tezos.contract.at(kycAddress)
        kycStorage          = await kycInstance.storage()

        debtControllerAddress   = contractDeployments.debtController.address
        debtControllerInstance  = await utils.tezos.contract.at(debtControllerAddress)
        debtControllerStorage   = await debtControllerInstance.storage()

        console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
    })

    beforeEach('storage', async () => {
        superAdminStorage       = await superAdminInstance.storage()
        kycStorage              = await kycInstance.storage()
        rwaTokenStorage         = await rwaTokenInstance.storage()
        debtControllerStorage   = await debtControllerInstance.storage()
    })

    describe('Initialise Token - set Token Metadata', function () {
        it('setTokenMetadata', async () => {
            try {

                await signerFactory(tezos, adminSk);
                const token_metadata_list = [
                    {
                        token_id : 0,
                        token_metadata : new MichelsonMap()
                    },
                    {
                        token_id : 1,
                        token_metadata : new MichelsonMap()
                    },
                    {
                        token_id : 2,
                        token_metadata : new MichelsonMap()
                    }
                ];

                const setTokenMetadataOperation = await rwaTokenInstance.methods.setTokenMetadata(token_metadata_list).send();
                await setTokenMetadataOperation.confirmation();

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Minting', function () {

        it('Admin should not be able to mint more than 1 token per token id (non-fungible)', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 2,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

                mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 1,
                        amount : 2,
                        address : bob.pkh 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

                mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 2,
                        amount : 2,
                        address : mallory.pkh 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

                // update storage
                rwaTokenStorage = await rwaTokenInstance.storage();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = bob.pkh;
                ledgerKey.token_id  = 1;
                const bobToken1Balance      = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = mallory.pkh;
                ledgerKey.token_id  = 2;
                const malloryToken2Balance  = await rwaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , undefined);
                assert.equal(bobToken1Balance       , undefined);
                assert.equal(malloryToken2Balance   , undefined);

            } catch (e) {
                console.log(e)
            }
        })

        it('Admin should be able to mint tokens', async () => {
            try {

                timestampBeforeMint = makeTimestamp(0);

                await signerFactory(tezos, adminSk);
                let mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 1,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 1,
                        amount : 1,
                        address : bob.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 2,
                        amount : 1,
                        address : mallory.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                timestampAfterMint = makeTimestamp(0);

            } catch (e) {
                console.log(e)
            }
        })

        it('Admin should not be able to mint additional amounts of tokens', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 1,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

                mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 1,
                        amount : 1,
                        address : bob.pkh 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

                mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 2,
                        amount : 1,
                        address : mallory.pkh 
                    }
                ]);
                chai.expect(mintOperation.send()).to.be.rejected;

                // update storage
                rwaTokenStorage = await rwaTokenInstance.storage();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = bob.pkh;
                ledgerKey.token_id  = 1;
                const bobToken1Balance      = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = mallory.pkh;
                ledgerKey.token_id  = 2;
                const malloryToken2Balance  = await rwaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , 1);
                assert.equal(bobToken1Balance       , 1);
                assert.equal(malloryToken2Balance   , 1);

                timestampAfterSecondMint = makeTimestamp(0);

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Burn', function () {

        it('Admin should not be able to burn more than what the user has', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 0,
                        amount : 2,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

                burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 1,
                        amount : 2,
                        address : bob.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

                burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 2,
                        amount : 2,
                        address : mallory.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })
        it('Admin should be able to burn tokens (different token ids belonging to different users)', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 0,
                        amount : 1,
                        address : alice.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();

                burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 1,
                        amount : 1,
                        address : bob.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();

                burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 2,
                        amount : 1,
                        address : mallory.pkh 
                    }
                ]).send();
                await burnOperation.confirmation();

                // update storage
                rwaTokenStorage = await rwaTokenInstance.storage();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = bob.pkh;
                ledgerKey.token_id  = 1;
                const bobToken1Balance      = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = mallory.pkh;
                ledgerKey.token_id  = 2;
                const malloryToken2Balance  = await rwaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , undefined);
                assert.equal(bobToken1Balance       , undefined);
                assert.equal(malloryToken2Balance   , undefined);

            } catch (e) {
                console.log(e)
            }
        })

        it('Admin should not be able to burn additional amounts of tokens', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 0,
                        amount : 1,
                        address : alice.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

                burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 1,
                        amount : 1,
                        address : bob.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

                burnOperation = await rwaTokenInstance.methods.burn([
                    {
                        token_id : 2,
                        amount : 1,
                        address : mallory.pkh 
                    }
                ]);
                chai.expect(burnOperation.send()).to.be.rejected;

                // update storage
                rwaTokenStorage = await rwaTokenInstance.storage();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = bob.pkh;
                ledgerKey.token_id  = 1;
                const bobToken1Balance      = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.owner     = mallory.pkh;
                ledgerKey.token_id  = 2;
                const malloryToken2Balance  = await rwaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , undefined);
                assert.equal(bobToken1Balance       , undefined);
                assert.equal(malloryToken2Balance   , undefined);

            } catch (e) {
                console.log(e)
            }
        })
    })


    describe('Pause', function () {

        it('Admin should be able to pause tokens', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let pauseOperation = await rwaTokenInstance.methods.pause().send();
                await pauseOperation.confirmation();

            } catch (e) {
                console.log(e)
            }
        })

        it('Non-admin (alice) should not be able to pause tokens', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let pauseOperation = await rwaTokenInstance.methods.pause();
                await chai.expect(pauseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Unpause', function () {

        it('Non-admin (alice) should not be able to unpause tokens', async () => {
            try {

                await signerFactory(tezos, alice.sk);
                let unpauseOperation = await rwaTokenInstance.methods.unpause();
                await chai.expect(unpauseOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('Admin should be able to unpause tokens', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let unpauseOperation = await rwaTokenInstance.methods.unpause().send();
                await unpauseOperation.confirmation();

            } catch (e) {
                console.log(e)
            }
        })
    })

    describe('Token Holder Calls', function () {

        it('Bootstrapping by issuing some tokens', async () => {
            try {

                await signerFactory(tezos, adminSk);
                let mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 0,
                        amount : 1,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 1,
                        amount : 1,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                mintOperation = await rwaTokenInstance.methods.mint([
                    {
                        token_id : 2,
                        amount : 1,
                        address : alice.pkh 
                    }
                ]).send();
                await mintOperation.confirmation();

                var ledgerKey = {
                    owner : alice.pkh,
                    token_id : 0
                };
                const aliceToken0Balance    = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.token_id  = 1;
                const aliceToken1Balance      = await rwaTokenStorage.ledger.get(ledgerKey);

                ledgerKey.token_id  = 2;
                const aliceToken2Balance  = await rwaTokenStorage.ledger.get(ledgerKey);

                assert.equal(aliceToken0Balance     , 1);
                assert.equal(aliceToken1Balance     , 1);
                assert.equal(aliceToken2Balance     , 1);

            } catch (e) {
                console.log(e)
            }
        })

        describe('Transfer', function () {

            it('Holder with no balance tries transfer', async () => {
                try {

                    await signerFactory(tezos, bob.sk);
                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : bob.pkh,
                            txs: [
                                {
                                    to_: mallory.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('Admin with no balance tries transfer', async () => {
                try {

                    await signerFactory(tezos, adminSk);
                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : admin,
                            txs: [
                                {
                                    to_: mallory.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('Admin tries transfer of third parties balance', async () => {
                try {

                    await signerFactory(tezos, adminSk);
                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : alice.pkh,
                            txs: [
                                {
                                    to_: mallory.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('Owner performs initial transfer of own balance', async () => {
                try {

                    await signerFactory(tezos, alice.sk);
                    timestampOne = makeTimestamp(0); // alice transfers 10 tokens to mallory

                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : alice.pkh,
                            txs: [
                                {
                                    to_: mallory.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]).send();
                    await transferOperation.confirmation();

                    wait(5000);
                    timestampTwo = makeTimestamp(0); // alice transfers 10 tokens to mallory

                } catch (e) {
                    console.log(e)
                }
            })

            it('Owner tries transfer of third party balance', async () => {
                try {

                    await signerFactory(tezos, alice.sk);
                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : mallory.pkh,
                            txs: [
                                {
                                    to_: bob.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

            it('Holder transfers own balance', async () => {
                try {

                    await signerFactory(tezos, mallory.sk);
                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : mallory.pkh,
                            txs: [
                                {
                                    to_: bob.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]).send();
                    await transferOperation.confirmation();

                } catch (e) {
                    console.log(e)
                }
            })

            it('Holder transfers too much', async () => {
                try {

                    await signerFactory(tezos, mallory.sk);
                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : mallory.pkh,
                            txs: [
                                {
                                    to_: bob.pkh,
                                    token_id: 0,
                                    amount: 2,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })

        })


        describe('Pause/Unpause', function () {

            it('Holder should not be able to transfer paused token', async () => {
                try {

                    await signerFactory(tezos, adminSk);
                    let pauseOperation = await rwaTokenInstance.methods.pause().send();
                    await pauseOperation.confirmation();

                    await signerFactory(tezos, mallory.sk);
                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : mallory.pkh,
                            txs: [
                                {
                                    to_: bob.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]);
                    await chai.expect(transferOperation.send()).to.be.rejected;

                } catch (e) {
                    console.log(e)
                }
            })


            it('Holder should be able to transfer unpaused token', async () => {
                try {

                    await signerFactory(tezos, adminSk);
                    const unpauseOperation = await rwaTokenInstance.methods.unpause().send();
                    await unpauseOperation.confirmation();

                    await signerFactory(tezos, bob.sk);
                    const transferOperation = await rwaTokenInstance.methods.transfer([
                        {
                            from_ : bob.pkh,
                            txs: [
                                {
                                    to_: mallory.pkh,
                                    token_id: 0,
                                    amount: 1,
                                },
                            ]
                        }
                    ]).send();
                    await transferOperation.confirmation();

                } catch (e) {
                    console.log(e)
                }
            })

        })

        describe('Token KYC', function () {

            before("Set token kyc", async () => {
                
                await signerFactory(tezos, adminSk);
                const setRuleEngineOperation = await rwaTokenInstance.methods.setTokenKyc(contractDeployments.kyc.address).send();
                await setRuleEngineOperation.confirmation();

                // check that transfer fails now
                const transferOperation = await rwaTokenInstance.methods.transfer([
                    {
                        from_ : alice.pkh,
                        txs: [
                            {
                                to_: mallory.pkh,
                                token_id: 0,
                                amount: 1,
                            },
                        ]
                    }
                ]);
                await chai.expect(transferOperation.send()).to.be.rejected;
            });

            // it('Only Admin can unfreeze', async () => {
            //     try {

            //         await signerFactory(tezos, alice.sk);
            //         let unfreezeAccountOperation = await freezeRuleEngineInstance.methods.unfreeze_account(alice.pkh);
            //         await chai.expect(unfreezeAccountOperation.send()).to.be.rejected;

            //         await signerFactory(tezos, adminSk);
            //         unfreezeAccountOperation = await freezeRuleEngineInstance.methods.unfreeze_account(alice.pkh).send();
            //         await unfreezeAccountOperation.confirmation();

            //         await signerFactory(tezos, alice.sk);
            //         transferOperation = await rwaTokenInstance.methods.transfer([
            //             {
            //                 from_ : alice.pkh,
            //                 txs: [
            //                     {
            //                         to_: mallory.pkh,
            //                         token_id: 0,
            //                         amount: 1,
            //                     },
            //                 ]
            //             }
            //         ]).send();
            //         await transferOperation.confirmation();

            //     } catch (e) {
            //         console.log(e)
            //     }
            // })

            // it('Bob still frozen', async () => {
            //     try {

            //         await signerFactory(tezos, alice.sk);
            //         const transferOperation = await rwaTokenInstance.methods.transfer([
            //             {
            //                 from_ : alice.pkh,
            //                 txs: [
            //                     {
            //                         to_: bob.pkh,
            //                         token_id: 0,
            //                         amount: 0,
            //                     },
            //                 ]
            //             }
            //         ]);
            //         await chai.expect(transferOperation.send()).to.be.rejected;

            //     } catch (e) {
            //         console.log(e)
            //     }
            // })

            // it('Unfreeze Bob', async () => {
            //     try {

            //         await signerFactory(tezos, adminSk);
            //         const unfreezeAccountOperation = await freezeRuleEngineInstance.methods.unfreeze_account(bob.pkh).send();
            //         await unfreezeAccountOperation.confirmation();

            //     } catch (e) {
            //         console.log(e)
            //     }
            // })
        })

        describe('Snapshots View Tests', function () {

            describe('View: getUserBalanceAtTimestamp', function () {

                describe('View: getUserBalanceAtTimestamp - basic snapshot check', function () {

                    it('Check user balance before mint (should be zero)', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 0);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should be 1)', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterMint
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after second mint (should be 1 since second mint fails)', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterSecondMint
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance (should fail), with negative start counter', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : -2
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance (should fail), with negative end counter', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : null,
                                endCounter : -2
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance (should fail), with negative start or end counter', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : -2,
                                endCounter : -2
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance (should fail), with non-existent token id', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 999,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })
                })

                describe('View: getUserBalanceAtTimestamp - user balance before mint', function () {

                    it('Check user balance before mint (should be zero), with start and end counter specified', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : 0,
                                endCounter : 2
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 0);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance before mint (should be zero), with only start counter specified', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : 0
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 0);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance before mint (should be zero), with only end counter specified', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : null,
                                endCounter: 2
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 0);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance before mint (should be zero), with start counter specified at its snapshot id (0) - works only for the first snapshot with id 0', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : 0
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 0);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance before mint (should be zero), with end counter as a very high number (999)', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : 0,
                                endCounter : 999
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 0);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance before mint (should fail), with start counter after given timestamp', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampBeforeMint,
                                startCounter : 2,
                                endCounter : 4
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })
                
                })

                describe('View: getUserBalanceAtTimestamp - user balance after first mint', function () {

                    it('Check user balance after mint (should be 1), with start and end counter specified within range', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterMint,
                                startCounter : 0,
                                endCounter : 2
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })


                    it('Check user balance after mint (should be 1), with only start counter specified', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterMint,
                                startCounter : 0
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should be 1), with only end counter specified', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterMint,
                                startCounter : null,
                                endCounter : 2
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should fail), with start counter at its snapshot id (1)', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            // snapshot for timestampAfterMint is at id 1
                            // - start counter should be less than id 1 (i.e. not inclusive)

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterMint,
                                startCounter : 1,
                                endCounter : 2
                            };

                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should be 1), with end counter as a very high number (999)', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterMint,
                                startCounter : 0,
                                endCounter : 999
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should fail), with start counter after given timestamp', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterMint,
                                startCounter : 2,
                                endCounter : 4
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })

                })

                describe('View: getUserBalanceAtTimestamp - user balance after second mint', function () {

                    it('Check user balance after mint (should be 1), with start and end counter specified within range', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterSecondMint,
                                startCounter : 0,
                                endCounter : 2
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })


                    it('Check user balance after mint (should be 1), with only start counter specified', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterSecondMint,
                                startCounter : 0
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should be 1), with only end counter specified', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterSecondMint,
                                startCounter : null,
                                endCounter : 3
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should fail), with start counter at its snapshot id (2)', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            // snapshot for timestampAfterMint is at id 2
                            // - start counter should be less than id 2 (i.e. not inclusive)

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterSecondMint,
                                startCounter : 2,
                                endCounter : 3
                            };

                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should be 1), with end counter as a very high number (999)', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterSecondMint,
                                startCounter : 0,
                                endCounter : 999
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey).executeView({ viewCaller : alice.pkh});
                            assert.equal(aliceTokenBalanceAtTimestamp, 1);

                        } catch (e) {
                            console.log(e)
                        }
                    })

                    it('Check user balance after mint (should fail), with start counter after given timestamp', async () => {
                        try {

                            await signerFactory(tezos, alice.sk);

                            const viewKey = {
                                tokenId : 0,
                                user : alice.pkh,
                                timestamp : timestampAfterSecondMint,
                                startCounter : 3,
                                endCounter : 5
                            };
                            const aliceTokenBalanceAtTimestamp = await rwaTokenInstance.contractViews.getUserBalanceAtTimestamp(viewKey);
                            await chai.expect(aliceTokenBalanceAtTimestamp.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                        } catch (e) {
                            console.log(e)
                        }
                    })

                })

            })

            describe('View: getUserSnapshots', function () {

                it('Get user snapshots (get the first two snapshots for a user)', async () => {
                    try {

                        await signerFactory(tezos, alice.sk);
                        
                        const viewKey = {
                            tokenId : 0,
                            user : alice.pkh,
                            startCounter : 0,
                            endCounter : 1
                        };
                        const userSnapshots = await rwaTokenInstance.contractViews.getUserSnapshots(viewKey).executeView({ viewCaller : alice.pkh});

                        // console.log("userSnapshots: ", userSnapshots);

                    } catch (e) {
                        console.log(e)
                    }
                })


                it('Get user snapshots (get the middle two snapshots for a user)', async () => {
                    try {

                        await signerFactory(tezos, alice.sk);
                        
                        const viewKey = {
                            tokenId : 0,
                            user : alice.pkh,
                            startCounter : 2,
                            endCounter : 3
                        };
                        const userSnapshots = await rwaTokenInstance.contractViews.getUserSnapshots(viewKey).executeView({ viewCaller : alice.pkh});

                        // console.log("userSnapshots: ", userSnapshots);

                    } catch (e) {
                        console.log(e)
                    }
                })


                it('Get user snapshots (no start and end counter specified)', async () => {
                    try {

                        await signerFactory(tezos, alice.sk);
                        
                        const viewKey = {
                            tokenId : 0,
                            user : alice.pkh
                        };
                        const userSnapshots = await rwaTokenInstance.contractViews.getUserSnapshots(viewKey).executeView({ viewCaller : alice.pkh});

                    } catch (e) {
                        console.log(e)
                    }
                })

                it('Get user snapshots (with very high end counter specified)', async () => {
                    try {

                        await signerFactory(tezos, alice.sk);
                        
                        const viewKey = {
                            tokenId : 0,
                            user : alice.pkh,
                            startCounter : null,
                            endCounter : 999
                        };
                        const userSnapshots = await rwaTokenInstance.contractViews.getUserSnapshots(viewKey).executeView({ viewCaller : alice.pkh});

                    } catch (e) {
                        console.log(e)
                    }
                })

                it('Get user snapshots should fail with start counter specified greater than number of user snapshots', async () => {
                    try {

                        await signerFactory(tezos, alice.sk);
                        
                        const viewKey = {
                            tokenId : 0,
                            user : alice.pkh,
                            startCounter : 100
                        };
                        const userSnapshots = await rwaTokenInstance.contractViews.getUserSnapshots(viewKey);
                        await chai.expect(userSnapshots.executeView({ viewCaller : alice.pkh})).to.be.rejected;

                    } catch (e) {
                        console.log(e)
                    }
                })
            })

        })


        // describe('Snapshots Stress Tests', function () {

        //     before('setup transfers', async() => {

        //         const numberOfTransfers = 300; // Number of times to perform the transfer
        //         const minAmount         = 1;  // Minimum token amount
        //         const maxAmount         = 1;  // Maximum token amount

        //         await performRandomTransfers(
        //             tezos,
        //             rwaTokenInstance,   // token 
        //             alice.pkh,          // sender address
        //             alice.sk,           // sender sk
        //             bob.pkh,            // receiver address
        //             bob.sk,             // receiver sk
        //             numberOfTransfers, 
        //             minAmount, 
        //             maxAmount
        //         );

        //         await performRandomTransfers(
        //             tezos,
        //             rwaTokenInstance,   // token 
        //             alice.pkh,          // sender address
        //             alice.sk,           // sender sk
        //             bob.pkh,            // receiver address
        //             bob.sk,             // receiver sk
        //             numberOfTransfers, 
        //             minAmount, 
        //             maxAmount
        //         );

        //         await performRandomTransfers(
        //             tezos,
        //             rwaTokenInstance,   // token 
        //             alice.pkh,          // sender address
        //             alice.sk,           // sender sk
        //             bob.pkh,            // receiver address
        //             bob.sk,             // receiver sk
        //             numberOfTransfers, 
        //             minAmount, 
        //             maxAmount
        //         );

        //         await performRandomTransfers(
        //             tezos,
        //             rwaTokenInstance,   // token 
        //             alice.pkh,          // sender address
        //             alice.sk,           // sender sk
        //             bob.pkh,            // receiver address
        //             bob.sk,             // receiver sk
        //             numberOfTransfers, 
        //             minAmount, 
        //             maxAmount
        //         );

        //     })

        //     it('Get user snapshots (no start and end counter specified)', async () => {
        //         try {

        //             await signerFactory(tezos, alice.sk);
                    
        //             const viewKey = {
        //                 tokenId : 0,
        //                 user : alice.pkh
        //             };
        //             const userSnapshots = await rwaTokenInstance.contractViews.getUserSnapshots(viewKey).executeView({ viewCaller : alice.pkh});
                    
        //             console.log("length: ",userSnapshots.length);
        //             console.log("------------------------")
        //             // console.log(userSnapshots);

        //         } catch (e) {
        //             console.log(e)
        //         }
        //     })


        // })

        // describe('Kill Switch', function () {

        //     it('Non-Admin cannot kill the token contract', async () => {
        //         try {

        //             await signerFactory(tezos, alice.sk);
        //             let killOperation = await rwaTokenInstance.methods.kill();
        //             await chai.expect(killOperation.send()).to.be.rejected;

        //             // update storage
        //             rwaTokenStorage = await rwaTokenInstance.storage();

        //             const aliceToken0Balance    = await rwaTokenStorage.ledger.get({owner : alice.pkh, token_id : 0});
        //             const bobToken0Balance      = await rwaTokenStorage.ledger.get({owner : bob.pkh, token_id : 0});
        //             const malloryToken0Balance  = await rwaTokenStorage.ledger.get({owner : mallory.pkh, token_id : 0});

        //             assert.notEqual(aliceToken0Balance      , null);
        //             assert.notEqual(bobToken0Balance        , null);
        //             assert.notEqual(malloryToken0Balance    , null);

        //         } catch (e) {
        //             console.log(e)
        //         }
        //     })

        //     it('Admin can kill the token contract', async () => {
        //         try {

        //             await signerFactory(tezos, adminSk);
        //             let killOperation = await rwaTokenInstance.methods.kill().send();
        //             await killOperation.confirmation();

        //             // update storage
        //             rwaTokenStorage = await rwaTokenInstance.storage();

        //             const aliceToken0Balance    = await rwaTokenStorage.ledger.get({owner : alice.pkh, token_id : 0});
        //             const aliceToken1Balance    = await rwaTokenStorage.ledger.get({owner : alice.pkh, token_id : 1});
        //             const aliceToken2Balance    = await rwaTokenStorage.ledger.get({owner : alice.pkh, token_id : 2});

        //             const bobToken0Balance      = await rwaTokenStorage.ledger.get({owner : bob.pkh, token_id : 0});
        //             const bobToken1Balance      = await rwaTokenStorage.ledger.get({owner : bob.pkh, token_id : 1});
        //             const bobToken2Balance      = await rwaTokenStorage.ledger.get({owner : bob.pkh, token_id : 2});

        //             const malloryToken0Balance  = await rwaTokenStorage.ledger.get({owner : mallory.pkh, token_id : 0});
        //             const malloryToken1Balance  = await rwaTokenStorage.ledger.get({owner : mallory.pkh, token_id : 1});
        //             const malloryToken2Balance  = await rwaTokenStorage.ledger.get({owner : mallory.pkh, token_id : 2});

        //             assert.equal(aliceToken0Balance     , null);
        //             assert.equal(aliceToken1Balance     , null);
        //             assert.equal(aliceToken2Balance     , null);
                    
        //             assert.equal(bobToken0Balance       , null);
        //             assert.equal(bobToken1Balance       , null);
        //             assert.equal(bobToken2Balance       , null);
                    
        //             assert.equal(malloryToken0Balance   , null);
        //             assert.equal(malloryToken1Balance   , null);
        //             assert.equal(malloryToken2Balance   , null);

        //         } catch (e) {
        //             console.log(e)
        //         }
        //     })

        //     it('Admin cannot kill the token contract after it has already been killed', async () => {
        //         try {

        //             await signerFactory(tezos, adminSk);
        //             let killOperation = await rwaTokenInstance.methods.kill();
        //             await chai.expect(killOperation.send()).to.be.rejected;

        //             // update storage
        //             rwaTokenStorage = await rwaTokenInstance.storage();

        //             const aliceToken2Balance = await rwaTokenStorage.ledger.get({owner : alice.pkh, token_id : 2});
        //             assert.equal(aliceToken2Balance , null);
                    
        //         } catch (e) {
        //             console.log(e)
        //         }
        //     })

        // })

    })

})
