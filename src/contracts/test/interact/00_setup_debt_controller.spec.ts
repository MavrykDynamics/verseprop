import { Utils } from "../helpers/Utils.js"

const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
chai.should()
const assert = require('chai').assert

// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import { contracts } from "../../env.js"

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { bob, eve, alice, mallory } from '../../scripts/sandbox/accounts.js'
import { GeneralContract, setGeneralContractLambdas } from '../helpers/deploymentTestHelper'

import { 
    signerFactory,
    updateOperators
} from '../helpers/helperFunctions.js'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Interact: Deploy Debt Controller', async () => {
  
    var utils: Utils
    var tezos

    let superAdmin, kyc, debtController

    let superAdminAddress, kycAddress, debtControllerAddress, usdtTokenAddress, debtNFTAddress

    let superAdminInstance, superAdminStorage
    let kycInstance, kycStorage
    let debtControllerInstance, debtControllerStorage
    let admin, adminSk, kycRegistrarSk

    let kycOperation, signOperation, superAdminOperation, actionCounter

    before('setup', async () => {
        try{

            const NETWORK_TO_MIGRATE_TO = process.env.NETWORK_TO_MIGRATE_TO || "development";
            console.log('network: ', NETWORK_TO_MIGRATE_TO);

            //----------------------------
            // Setup admin signers and addresses depending on network
            //----------------------------

            if(NETWORK_TO_MIGRATE_TO == "mainnet"){
                
                admin                   = bob.pkh
                adminSk                 = bob.sk

                kycRegistrarSk          = bob.sk

                usdtTokenAddress        = contracts.mainnet.usdt;

            } else if (NETWORK_TO_MIGRATE_TO == "atlasnet"){
                
                admin                   = bob.pkh
                adminSk                 = bob.sk

                kycRegistrarSk          = bob.sk

                usdtTokenAddress        = contracts.atlasnet.usdt;

            } else if (NETWORK_TO_MIGRATE_TO == "development"){
                
                admin                   = bob.pkh
                adminSk                 = bob.sk

                kycRegistrarSk          = bob.sk

                usdtTokenAddress        = contracts.local.usdt;

            }

            //----------------------------
            // Set signer to admin
            //----------------------------

            utils = new Utils()
            await utils.init(adminSk)
            tezos = utils.tezos

            await signerFactory(tezos, adminSk);

            //----------------------------
            // Setup contracts
            //----------------------------

            superAdminInstance              = await utils.tezos.contract.at(superAdminAddress)
            superAdminStorage               = await superAdminInstance.storage()

            kycInstance                     = await utils.tezos.contract.at(kycAddress);
            kycStorage                      = await kycInstance.storage()

            debtControllerInstance          = await utils.tezos.contract.at(debtControllerAddress);
            debtControllerStorage           = await debtControllerInstance.storage()

        } catch(e){
            console.dir(e, {depth: 5})
        }

    })


    it('deploy superAdmin contract', async () => {
        try {

            // originate contract
            superAdmin = await GeneralContract.originate(utils.tezos, "superAdmin", superAdminStorage);
            superAdminAddress = superAdmin.contract.address

            // Set Lambdas
            await setGeneralContractLambdas(tezos, "superAdmin", superAdmin.contract)

        } catch (e) {
            console.log(e)
        }
    })

    it('deploy KYC contract', async () => {
        try {

            // set storage
            kycStorage.superAdmin = admin

            // originate contract
            kyc = await GeneralContract.originate(utils.tezos, "kyc", kycStorage);
            kycAddress = kyc.contract.address
        
            // Set Lambdas
            await setGeneralContractLambdas(tezos, "kyc", kyc.contract)

        } catch (e) {
            console.log(e)
        }
    })

    it('deploy debtController contract', async () => {
        try {

            // set storage
            debtControllerStorage.kycAddress = kycAddress

            // originate contract
            debtController = await GeneralContract.originate(utils.tezos, "debtController", debtControllerStorage)
            debtControllerAddress = debtController.contract.address
        
            // Set Lambdas
            await setGeneralContractLambdas(tezos, "debtController", debtController.contract)

        } catch (e) {
            console.log(e)
        }
    })

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
                memberAddress : admin,
                country : country,
                region : region,
                investorType : investorType
            },
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


    it(`-- interaction complete --`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})