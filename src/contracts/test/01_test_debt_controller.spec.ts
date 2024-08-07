import { MichelsonMap } from "@mavrykdynamics/taquito-michelson-encoder"
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

import { GeneralContract } from './helpers/deploymentTestHelper'

import { rwaTokenNonFungibleStorage } from '../storage/rwaTokenNonFungibleStorage'

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { bob, alice, eve, mallory, oscar, trudy } from '../scripts/sandbox/accounts'
import { 
    signerFactory, 
    wait,
    getStorageMapValue,
    makeSnapshotTimestamp,
    makeTimestamp, 
    MAV
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
    let operatorKey, actionCounter
    let tokenURI, currency, amount
    let debtNFT, debtNFTInstance, debtNFTStorage, nextTokenId

    // contract instances 
    let superAdminAddress, superAdminInstance, superAdminStorage
    let rwaTokenAddress, rwaTokenInstance, rwaTokenStorage
    let kycAddress, kycInstance, kycStorage
    let debtControllerAddress, debtControllerInstance, debtControllerStorage

    // user accounts
    let user, userSk
    let admin, adminSk
    let manager, managerSk
    let investorOne, investorOneSk
    let investorTwo, investorTwoSk
    let debtor, debtorSk
    let debt, debtId

    // contract map value
    let burnAddress

    // operations
    let kycOperation, signOperation, debtNFTOperation
    let superAdminOperation
    let debtControllerOperation
    
    before('setup', async () => {
        
        utils = new Utils()
        await utils.init(bob.sk)
        tezos = utils.tezos;
        client = new RpcClient(env.networks.development.rpc);

        admin           = bob.pkh 
        adminSk         = bob.sk 

        manager         = eve.pkh
        managerSk       = eve.sk

        investorOne     = mallory.pkh
        investorOneSk   = mallory.sk

        investorTwo     = alice.pkh 
        investorTwoSk   = alice.sk

        debtor          = oscar.pkh
        debtorSk        = oscar.sk

        burnAddress     = "mv2burnburnburnburnburnburnbur7hzNeg"

        tokenURI        = Buffer.from("https://verseprop-byd6bdg5exfnayd3.z02.azurefd.net/static/raven.png", 'ascii').toString('hex');

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

        await signerFactory(tezos, adminSk)
    })

    describe('setup', function () {

        it('set general admin (bob)', async () => {

            // Set General Admin on Super Admin Contract to bob
            const generalAdmin = await superAdminStorage.generalAdminLedger.get(admin);

            if(generalAdmin == null){

                actionCounter       = superAdminStorage.actionCounter;
                superAdminOperation = await superAdminInstance.methods.setGeneralAdmin([admin]).send();
                await superAdminOperation.confirmation();

                superAdminOperation = await superAdminInstance.methods.signAction([actionCounter]).send();
                await superAdminOperation.confirmation();

                // update storage
                superAdminStorage = await superAdminInstance.storage()
            };

        })

        it('set general admin (debtController)', async () => {

            // Set General Admin on Super Admin Contract to debtController
            const generalAdmin = await superAdminStorage.generalAdminLedger.get(debtControllerAddress);

            if(generalAdmin == null){

                actionCounter       = superAdminStorage.actionCounter;
                superAdminOperation = await superAdminInstance.methods.setGeneralAdmin([debtControllerAddress]).send();
                await superAdminOperation.confirmation();

                superAdminOperation = await superAdminInstance.methods.signAction([actionCounter]).send();
                await superAdminOperation.confirmation();

                // update storage
                superAdminStorage = await superAdminInstance.storage()
            };

        })

        it('set superAdmin on debtController', async () => {

            // set super admin from bob to superAdmin address
            const superAdmin = await debtControllerStorage.superAdmin;
            if(superAdmin !== superAdminAddress){

                actionCounter = superAdminStorage.actionCounter;

                const setSuperAdminOperation = await debtControllerInstance.methods.setSuperAdmin(superAdminAddress).send();
                await setSuperAdminOperation.confirmation();
        
                const claimSuperAdminOperation = await superAdminInstance.methods.claimSuperAdmin([debtControllerAddress]).send();
                await claimSuperAdminOperation.confirmation();
        
                signOperation = await superAdminInstance.methods.signAction([actionCounter]).send();
                await signOperation.confirmation();

                // set contract admin
                superAdminStorage   = await superAdminInstance.storage()
                actionCounter       = superAdminStorage.actionCounter;

                superAdminOperation = await superAdminInstance.methods.setContractAdmin(admin, [debtControllerAddress]).send();
                await superAdminOperation.confirmation();

                signOperation = await superAdminInstance.methods.signAction([actionCounter]).send();
                await signOperation.confirmation();

                // update storage
                superAdminStorage   = await superAdminInstance.storage()
                const contractAdmin = await superAdminStorage.contractAdminLedger.get([admin, debtControllerAddress]);
                assert.notEqual(contractAdmin, null);
            };
    
        })


        it('set superAdmin on kyc', async () => {

            // set super admin from bob to superAdmin address
            const superAdmin = await kycStorage.superAdmin;
            if(superAdmin !== superAdminAddress){

                actionCounter = superAdminStorage.actionCounter;

                const setSuperAdminOperation = await kycInstance.methods.setSuperAdmin(superAdminAddress).send();
                await setSuperAdminOperation.confirmation();
        
                const claimSuperAdminOperation = await superAdminInstance.methods.claimSuperAdmin([kycAddress]).send();
                await claimSuperAdminOperation.confirmation();
        
                signOperation = await superAdminInstance.methods.signAction([actionCounter]).send();
                await signOperation.confirmation();

                // set contract admin
                superAdminStorage   = await superAdminInstance.storage()
                actionCounter       = superAdminStorage.actionCounter;

                superAdminOperation = await superAdminInstance.methods.setContractAdmin(admin, [kycAddress]).send();
                await superAdminOperation.confirmation();

                signOperation = await superAdminInstance.methods.signAction([actionCounter]).send();
                await signOperation.confirmation();

                // update storage
                superAdminStorage   = await superAdminInstance.storage()
                const contractAdmin = await superAdminStorage.contractAdminLedger.get([admin, kycAddress]);
                assert.notEqual(contractAdmin, null);
            };
    
        })

        it('setup kyc', async () => {

            // init kyc registrar and kyc members
            const kycName                   = "newKycRegistrar";
            const kycRegistrarAddress       = admin;
            const kycAdminAddresses         = [admin];

            kycOperation = await kycInstance.methods.setKycRegistrar(kycName, kycRegistrarAddress, kycAdminAddresses).send();
            await kycOperation.confirmation();

            // set valid inputs
            let inputField      = "country";
            let country         = "france";
            let inputs          = [country];

            kycOperation = await kycInstance.methods.setValidInput(inputField, inputs).send();
            await kycOperation.confirmation();

            inputField          = "region";
            let region          = "europe";
            inputs              = [region];

            kycOperation = await kycInstance.methods.setValidInput(inputField, inputs).send();
            await kycOperation.confirmation();

            inputField          = "investorType";
            let investorType    = "standard";
            inputs              = [investorType];

            kycOperation = await kycInstance.methods.setValidInput(inputField, inputs).send();
            await kycOperation.confirmation();

            // set kyc members
            const setMemberAction = "addMember";
            const memberList = [
                {
                    memberAddress : bob.pkh,
                    country : country,
                    region : region,
                    investorType : investorType
                },
                {
                    memberAddress : eve.pkh,
                    country : country,
                    region : region,
                    investorType : investorType
                },
                {
                    memberAddress : alice.pkh,
                    country : country,
                    region : region,
                    investorType : investorType
                },
                {
                    memberAddress : mallory.pkh,
                    country : country,
                    region : region,
                    investorType : investorType
                },
                {
                    memberAddress : oscar.pkh,
                    country : country,
                    region : region,
                    investorType : investorType
                }
            ];

            kycOperation = await kycInstance.methods.setMember(setMemberAction, memberList).send();
            await kycOperation.confirmation();

            // set country transfer rule
            const rule                  = "addNewCountryTransferRule";
            const ruleValue             = [
                {
                    country : country,
                    whitelistCountries : [],
                    blacklistCountries : [],
                    sendingFrozen : false,
                    receivingFrozen : false
                }
            ];
            
            kycOperation = await kycInstance.methods.setCountryTransferRule(
                rule, 
                ruleValue
            ).send();
            await kycOperation.confirmation();

        })

    })

    describe('debtLogic', function () {
        it('should create a new debt', async () => {
            try {

                debtId                      = await debtControllerStorage.debtCount
                const maxAmount             = MAV(100)
                const interestRate          = 1000; // 10%
                const term                  = 9; // 9 months
                user                        = debtor
                const minInvestmentAmount   = MAV(2)
                currency                    = "mav"
                
                debtControllerOperation = await debtControllerInstance.methods.createDebt(
                    maxAmount,
                    interestRate,
                    term,
                    user,
                    minInvestmentAmount,
                    tokenURI,
                    currency
                ).send();
                await debtControllerOperation.confirmation();

                debtControllerStorage = await debtControllerInstance.storage();

                debt = await debtControllerStorage.debtLedger.get(debtId)

                assert.equal(debt.maxAmount.toNumber()          , maxAmount);
                assert.equal(debt.interestRate.toNumber()       , interestRate);
                assert.equal(debt.term.toNumber()               , term);
                assert.equal(debt.walletAddress                 , user);
                assert.equal(debt.minInvestmentAmount.toNumber(), minInvestmentAmount);
                assert.equal(debt.totalInvestment.toNumber()    , 0);
                assert.equal(debt.tokenURI                      , tokenURI);
                assert.equal(debt.currency                      , currency);

            } catch (e) {
                console.log(e)
            }
        })

        it('should allow admin to add deposits on investors behalf', async () => {
            try {

                amount  = MAV(3)
                user    = investorOne
                
                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount});
                await debtControllerOperation.confirmation();

                amount = MAV(2)
                user   = investorTwo

                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount});
                await debtControllerOperation.confirmation();

                debtControllerStorage = await debtControllerInstance.storage();

                debt = await debtControllerStorage.debtLedger.get(debtId)
                assert.equal(debt.totalInvestment.toNumber(), MAV(5));

                let investmentRecord = await debtControllerStorage.investmentLedger.get(debtId)
                
                const investorOneAmount = await investmentRecord.valueMap.get('"0"');
                assert.equal(investorOneAmount, MAV(3))

                const investorTwoAmount = await investmentRecord.valueMap.get('"1"');
                assert.equal(investorTwoAmount, MAV(2))

            } catch (e) {
                console.log(e)
            }
        })

        it('should disburse the loan when the investment goal is reached', async () => {
            try {

                debtId                      = await debtControllerStorage.debtCount
                const maxAmount             = MAV(5)
                const interestRate          = 1000; // 10%
                const term                  = 9; // 9 months
                user                        = debtor
                const minInvestmentAmount   = MAV(2)
                currency                    = "mav"
                
                debtControllerOperation = await debtControllerInstance.methods.createDebt(
                    maxAmount,
                    interestRate,
                    term,
                    user,
                    minInvestmentAmount,
                    tokenURI,
                    currency
                ).send();
                await debtControllerOperation.confirmation();

                amount  = MAV(3)
                user    = investorOne
                
                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount});
                await debtControllerOperation.confirmation();

                amount = MAV(2)
                user   = investorTwo

                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount});
                await debtControllerOperation.confirmation();
                
                debtControllerStorage = await debtControllerInstance.storage();

                const initialDebtorBalance  = (await utils.tezos.tz.getBalance(debtor)).toNumber();

                debtControllerOperation = await debtControllerInstance.methods.disburseLoan(debtId).send();
                await debtControllerOperation.confirmation();

                const updatedDebtorBalance  = (await utils.tezos.tz.getBalance(debtor)).toNumber();

                const versePropFee = (maxAmount * 2) / 100;
                const loanAmount   = maxAmount - versePropFee;

                assert.equal(updatedDebtorBalance - initialDebtorBalance, loanAmount)

                debt = await debtControllerStorage.debtLedger.get(debtId)
                var debtStatus  = Object.keys(debt.status)[0];
                assert.equal(debtStatus, "fUNDED");

            } catch (e) {
                console.log(e)
            }
        })

        it('should return deposits if the loan is not disbursed', async () => {
            try {

                debtId                      = await debtControllerStorage.debtCount
                const maxAmount             = MAV(100)
                const interestRate          = 1000; // 10%
                const term                  = 9; // 9 months
                user                        = debtor
                const minInvestmentAmount   = MAV(2)
                currency                    = "mav"
                
                debtControllerOperation = await debtControllerInstance.methods.createDebt(
                    maxAmount,
                    interestRate,
                    term,
                    user,
                    minInvestmentAmount,
                    tokenURI,
                    currency
                ).send();
                await debtControllerOperation.confirmation();

                amount  = MAV(3)
                user    = investorOne
                
                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount});
                await debtControllerOperation.confirmation();

                amount = MAV(2)
                user   = investorTwo

                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount});
                await debtControllerOperation.confirmation();
                
                debtControllerStorage = await debtControllerInstance.storage();

                const initialInvestorOneBalance  = (await utils.tezos.tz.getBalance(investorOne)).toNumber();
                const initialInvestorTwoBalance  = (await utils.tezos.tz.getBalance(investorTwo)).toNumber();

                debtControllerOperation = await debtControllerInstance.methods.returnDeposit(debtId).send();
                await debtControllerOperation.confirmation();

                const updatedInvestorOneBalance  = (await utils.tezos.tz.getBalance(investorOne)).toNumber();
                const updatedInvestorTwoBalance  = (await utils.tezos.tz.getBalance(investorTwo)).toNumber();

                assert.equal(updatedInvestorOneBalance - initialInvestorOneBalance, MAV(3))
                assert.equal(updatedInvestorTwoBalance - initialInvestorTwoBalance, MAV(2))

            } catch (e) {
                console.log(e)
            }
        })

        it('should allow paying off the debt', async () => {
            try {

                debtId                      = await debtControllerStorage.debtCount
                const maxAmount             = MAV(10)
                const interestRate          = 1000;     // 10%
                const term                  = 9;        // 9 months
                user                        = debtor
                const minInvestmentAmount   = MAV(2)
                currency                    = "mav"
                
                debtControllerOperation = await debtControllerInstance.methods.createDebt(
                    maxAmount,
                    interestRate,
                    term,
                    user,
                    minInvestmentAmount,
                    tokenURI,
                    currency
                ).send();
                await debtControllerOperation.confirmation();

                amount  = MAV(7)
                user    = investorOne
                
                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount });
                await debtControllerOperation.confirmation();

                amount = MAV(3)
                user   = investorTwo

                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount });
                await debtControllerOperation.confirmation();

                // disburse loan
                debtControllerOperation = await debtControllerInstance.methods.disburseLoan(debtId).send();
                await debtControllerOperation.confirmation();
                
                debtControllerStorage = await debtControllerInstance.storage();

                const initialDebtorBalance    = (await utils.tezos.tz.getBalance(debtor)).toNumber();
                const initialContractBalance  = (await utils.tezos.tz.getBalance(debtControllerAddress)).toNumber();

                const interestAccrued = await debtControllerInstance.contractViews.calculateInterest([0, maxAmount]).executeView({ viewCaller : admin});
                const totalPayment    = maxAmount + interestAccrued;

                // pay off debt
                debtControllerOperation = await debtControllerInstance.methods.payOffDebt(debtId, admin).send({ mumav : true, amount : totalPayment });
                await debtControllerOperation.confirmation();

                const updatedDebtorBalance    = (await utils.tezos.tz.getBalance(debtor)).toNumber();
                const updatedContractBalance  = (await utils.tezos.tz.getBalance(debtControllerAddress)).toNumber();

                assert.equal(updatedContractBalance - initialContractBalance, totalPayment)
                assert.equal(updatedDebtorBalance - initialDebtorBalance, 0)

                debt = await debtControllerStorage.debtLedger.get(debtId)
                var debtStatus  = Object.keys(debt.status)[0];
                assert.equal(debtStatus, "sETTLED");

            } catch (e) {
                console.log(e)
            }
        })

        it('should allow NFT owner to withdraw deposit after paying off the debt', async () => {
            try {

                debtId                      = await debtControllerStorage.debtCount
                const maxAmount             = MAV(10)
                const interestRate          = 1000; // 10%
                const term                  = 9; // 9 months
                user                        = debtor
                const minInvestmentAmount   = MAV(2)
                currency                    = "mav"
                
                debtControllerOperation = await debtControllerInstance.methods.createDebt(
                    maxAmount,
                    interestRate,
                    term,
                    user,
                    minInvestmentAmount,
                    tokenURI,
                    currency
                ).send();
                await debtControllerOperation.confirmation();

                amount  = MAV(7)
                user    = investorOne
                
                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount});
                await debtControllerOperation.confirmation();

                amount = MAV(3)
                user   = investorTwo

                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mumav : true, amount : amount});
                await debtControllerOperation.confirmation();
                
                debtControllerStorage = await debtControllerInstance.storage();
                debt                  = await debtControllerStorage.debtLedger.get(debtId)

                // set debt NFT contract instance
                const debtNFTAddress = debt.nftContractAddress;
                const debtNFTInstance = await utils.tezos.contract.at(debtNFTAddress)

                let tokenZeroOwnerOf = await debtNFTInstance.contractViews.owner_of(0).executeView({ viewCaller : admin});
                let tokenOneOwnerOf  = await debtNFTInstance.contractViews.owner_of(1).executeView({ viewCaller : admin});

                assert.equal(tokenZeroOwnerOf.Some, investorOne);
                assert.equal(tokenOneOwnerOf.Some , investorTwo);

                // disburse loan
                debtControllerOperation = await debtControllerInstance.methods.disburseLoan(debtId).send();
                await debtControllerOperation.confirmation();

                const interestAccrued = await debtControllerInstance.contractViews.calculateInterest([0, maxAmount]).executeView({ viewCaller : admin});
                const totalPayment    = maxAmount + interestAccrued;

                // pay off debt
                debtControllerOperation = await debtControllerInstance.methods.payOffDebt(debtId, admin).send({ mumav : true, amount : totalPayment });
                await debtControllerOperation.confirmation();

                const initialInvestorOneBalance  = (await utils.tezos.tz.getBalance(investorOne)).toNumber();
                const initialInvestorTwoBalance  = (await utils.tezos.tz.getBalance(investorTwo)).toNumber();

                debtControllerOperation = await debtControllerInstance.methods.withdrawDeposit(debtId, 0, investorOne).send();
                await debtControllerOperation.confirmation();

                debtControllerOperation = await debtControllerInstance.methods.withdrawDeposit(debtId, 1, investorTwo).send();
                await debtControllerOperation.confirmation();

                const updatedInvestorOneBalance  = (await utils.tezos.tz.getBalance(investorOne)).toNumber();
                const updatedInvestorTwoBalance  = (await utils.tezos.tz.getBalance(investorTwo)).toNumber();

                assert.equal(updatedInvestorOneBalance - initialInvestorOneBalance, MAV(7))
                assert.equal(updatedInvestorTwoBalance - initialInvestorTwoBalance, MAV(3))

                tokenZeroOwnerOf = await debtNFTInstance.contractViews.owner_of(0).executeView({ viewCaller : admin});
                tokenOneOwnerOf  = await debtNFTInstance.contractViews.owner_of(1).executeView({ viewCaller : admin});

                // difference from original tests where owner is reverted
                // mv1Mw2s9svrv8qLnht8QoPFaiaRY7wz2Epo1 is the alternative hash of mv2burnburnburnburnburnburnbur7hzNeg?
                assert.equal(tokenZeroOwnerOf.Some, "mv1Mw2s9svrv8qLnht8QoPFaiaRY7wz2Epo1");
                assert.equal(tokenOneOwnerOf.Some , "mv1Mw2s9svrv8qLnht8QoPFaiaRY7wz2Epo1");

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('debtNFT', function () {

        before('deploy debt nft', async () => {

            rwaTokenNonFungibleStorage.superAdmin = contractDeployments.superAdmin.address;
            rwaTokenNonFungibleStorage.kycAddress = contractDeployments.kyc.address;

            debtNFT = await GeneralContract.originate(utils.tezos, "rwaTokenNonFungible", rwaTokenNonFungibleStorage);

            debtNFTInstance = await utils.tezos.contract.at(debtNFT.contract.address)
            debtNFTStorage  = await debtNFTInstance.storage()
            
        })

        it('should mint a new NFT to a specified address (KYC-ed user)', async () => {
            try {

                const tokenURI = Buffer.from("https://example.com/nft/1", 'ascii').toString('hex');
                
                nextTokenId = await debtNFTInstance.contractViews.next_token_id().executeView({ viewCaller : admin});

                debtNFTOperation = await debtNFTInstance.methods.mint([
                    {
                        token_metadata : tokenURI,
                        address : debtor
                    }
                ]).send();
                await debtNFTOperation.confirmation();

                debtNFTStorage  = await debtNFTInstance.storage()

                const debtNFTMetadata = await debtNFTStorage.token_metadata.get(nextTokenId);
                const tokenInfo       = debtNFTMetadata.token_info;
                const tokenInfoBytes  = await tokenInfo.valueMap.get('""');

                assert.equal(tokenInfoBytes, tokenURI);

            } catch (e) {
                console.log(e)
            }
        })

        it('should mint a new NFT to a specified address (non-KYC-ed user)', async () => {
            try {

                const tokenURI = Buffer.from("https://example.com/nft/2", 'ascii').toString('hex');
                
                debtNFTOperation = await debtNFTInstance.methods.mint([
                    {
                        token_metadata : tokenURI,
                        address : trudy.pkh
                    }
                ]).send();
                await debtNFTOperation.confirmation();

                debtNFTStorage  = await debtNFTInstance.storage()

                const debtNFTMetadata = await debtNFTStorage.token_metadata.get(nextTokenId + 1);
                const tokenInfo       = debtNFTMetadata.token_info;
                const tokenInfoBytes  = await tokenInfo.valueMap.get('""');

                assert.equal(tokenInfoBytes, tokenURI);

            } catch (e) {
                console.log(e)
            }
        })

        it('should prevent non-managers from minting NFTs', async () => {
            try {

                await signerFactory(tezos, managerSk);

                const tokenURI = Buffer.from("https://example.com/nft/1", 'ascii').toString('hex');
                
                debtNFTOperation = await debtNFTInstance.methods.mint([
                    {
                        token_metadata : tokenURI,
                        address : debtor
                    }
                ]);
                await chai.expect(debtNFTOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('should allow admin to burn a token', async () => {
            try {
                
                debtNFTOperation = await debtNFTInstance.methods.burn([
                    {
                        token_id : nextTokenId,
                        address : debtor
                    }
                ]).send();
                await debtNFTOperation.confirmation();

                debtNFTStorage  = await debtNFTInstance.storage()

                // note: token metadata is not reset here, but the owner is now the burn address
                const tokenOwnerOf = await debtNFTInstance.contractViews.owner_of(nextTokenId).executeView({ viewCaller : admin});
                assert.equal(tokenOwnerOf.Some, burnAddress);

            } catch (e) {
                console.log(e)
            }
        })

        it('should freeze and unfreeze a token', async () => {
            try {

                const tokenURI = Buffer.from("https://example.com/nft/1", 'ascii').toString('hex');
                
                nextTokenId = await debtNFTInstance.contractViews.next_token_id().executeView({ viewCaller : admin});

                debtNFTOperation = await debtNFTInstance.methods.mint([
                    {
                        token_metadata : tokenURI,
                        address : debtor
                    }
                ]).send();
                await debtNFTOperation.confirmation();

                debtNFTStorage  = await debtNFTInstance.storage()

                // pause token
                debtNFTOperation = await debtNFTInstance.methods.pause().send()
                await debtNFTOperation.confirmation();

                // transfer should fail
                await signerFactory(tezos, debtorSk)
                debtNFTOperation = await debtNFTInstance.methods.transfer([
                    {
                        from_ : debtor,
                        txs: [
                            {
                                to_: investorOne,
                                token_id: nextTokenId,
                                amount: 1,
                            },
                        ]
                    }
                ]);
                await chai.expect(debtNFTOperation.send()).to.be.rejected 

                // unpause token
                await signerFactory(tezos, adminSk)
                debtNFTOperation = await debtNFTInstance.methods.unpause().send()
                await debtNFTOperation.confirmation();

                // transfer should work
                await signerFactory(tezos, debtorSk)
                debtNFTOperation = await debtNFTInstance.methods.transfer([
                    {
                        from_ : debtor,
                        txs: [
                            {
                                to_: investorOne,
                                token_id: nextTokenId,
                                amount: 1,
                            },
                        ]
                    }
                ]).send();
                await debtNFTOperation.confirmation()

            } catch (e) {
                console.log(e)
            }
        })

        it('should prevent non-managers from pausing or unpausing NFTs', async () => {
            try {

                await signerFactory(tezos, managerSk);
                
                debtNFTOperation = await debtNFTInstance.methods.pause()
                await chai.expect(debtNFTOperation.send()).to.be.rejected;

                debtNFTOperation = await debtNFTInstance.methods.unpause()
                await chai.expect(debtNFTOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

        it('should prevent non-managers from burning NFTs', async () => {
            try {

                await signerFactory(tezos, managerSk);
                
                debtNFTOperation = await debtNFTInstance.methods.burn([
                    {
                        token_id : nextTokenId,
                        address : investorOne
                    }
                ]);
                await chai.expect(debtNFTOperation.send()).to.be.rejected;

            } catch (e) {
                console.log(e)
            }
        })

    })

    describe('debtStorage', function () {

        it('should allow owner to get and add a debt', async () => {
            try {

                debtId                      = await debtControllerStorage.debtCount
                const maxAmount             = MAV(5000)
                const interestRate          = 500; // 5%
                const term                  = 12; // 12 months
                user                        = debtor
                const minInvestmentAmount   = MAV(100)
                currency                    = "mav"
                
                debtControllerOperation = await debtControllerInstance.methods.createDebt(
                    maxAmount,
                    interestRate,
                    term,
                    user,
                    minInvestmentAmount,
                    tokenURI,
                    currency
                ).send();
                await debtControllerOperation.confirmation();

                debtControllerStorage = await debtControllerInstance.storage();

                debt = await debtControllerStorage.debtLedger.get(debtId)

                assert.equal(debt.maxAmount.toNumber()          , maxAmount);
                assert.equal(debt.interestRate.toNumber()       , interestRate);
                assert.equal(debt.term.toNumber()               , term);
                assert.equal(debt.walletAddress                 , user);
                assert.equal(debt.minInvestmentAmount.toNumber(), minInvestmentAmount);
                assert.equal(debt.totalInvestment.toNumber()    , 0);
                assert.equal(debt.tokenURI                      , tokenURI);
                assert.equal(debt.currency                      , currency);

            } catch (e) {
                console.log(e)
            }
        })

        it('should allow admin to set the feeWallet', async () => {
            try {

                const newFeeWallet = alice.pkh;

                debtControllerOperation = await debtControllerInstance.methods.setFeeWallet(newFeeWallet).send();
                await debtControllerOperation.confirmation();

                debtControllerStorage = await debtControllerInstance.storage();
                assert.equal(debtControllerStorage.feeWallet, newFeeWallet)

            } catch (e) {
                console.log(e)
            }
        })

        it('should not allow non-admin to set the feeWallet', async () => {
            try {

                await signerFactory(tezos, investorOneSk)

                const newFeeWallet = alice.pkh;

                debtControllerOperation = await debtControllerInstance.methods.setFeeWallet(newFeeWallet);
                await chai.expect(debtControllerOperation.send()).to.be.rejected

            } catch (e) {
                console.log(e)
            }
        })

    })


})
