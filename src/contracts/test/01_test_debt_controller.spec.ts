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

import { bob, alice, eve, mallory, oscar } from '../scripts/sandbox/accounts'
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

    // contract instances 
    let superAdminAddress, superAdminInstance, superAdminStorage
    let rwaTokenAddress, rwaTokenInstance, rwaTokenStorage
    let kycAddress, kycInstance, kycStorage
    let debtControllerAddress, debtControllerInstance, debtControllerStorage

    // user accounts
    let user, userSk
    let admin, adminSk
    let manager, managerSk
    let sender, receiver
    let investorOne, investorOneSk
    let investorTwo, investorTwoSk
    let debtor, debtorSk
    let debt, debtId

    // contract map value
    let storageMap
    let contractMapKey
    let initialContractMapValue
    let updatedContractMapValue

    // operations
    let transferOperation, kycOperation, signOperation
    let superAdminOperation
    let updateOperatorsOperation
    let removeOperatorsOperation
    let setAdminOperation
    let resetAdminOperation
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

            await signerFactory(tezos, adminSk);
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

                await signerFactory(tezos, adminSk);

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

                await signerFactory(tezos, adminSk);

                amount  = MAV(3)
                user    = investorOne
                
                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mutez : true, amount : amount});
                await debtControllerOperation.confirmation();

                amount = MAV(2)
                user   = investorTwo

                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mutez : true, amount : amount});
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

                await signerFactory(tezos, adminSk);

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
                ).send({ mutez : true, amount : amount});
                await debtControllerOperation.confirmation();

                amount = MAV(2)
                user   = investorTwo

                debtControllerOperation = await debtControllerInstance.methods.addDeposit(
                    debtId,
                    amount,
                    user
                ).send({ mutez : true, amount : amount});
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

    })

})
