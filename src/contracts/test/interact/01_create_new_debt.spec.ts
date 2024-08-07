import { Utils } from "../helpers/Utils"

const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
chai.should()

// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import { contracts } from "../../env.js"

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { bob, eve, alice, mallory } from '../../scripts/sandbox/accounts.js'

import { 
    signerFactory,
    updateOperators,
    MAV
} from '../helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Interact: Create New Debt', async () => {
  
    var utils: Utils
    var tezos

    let tokenURI

    let superAdminAddress, kycAddress, debtControllerAddress, usdtTokenAddress

    let superAdminInstance, kycInstance, debtControllerInstance
    let superAdminStorage, kycStorage, debtControllerStorage
    let admin, adminSk, kycRegistrarSk
    let maxAmount, minInvestmentAmount, currency, interestRate, term, walletAddress

    let debtControllerOperation

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

                superAdminAddress       = contracts.mainnet.superAdmin;
                kycAddress              = contracts.mainnet.kyc;
                usdtTokenAddress        = contracts.mainnet.usdt;
                debtControllerAddress   = contracts.mainnet.debtController

            } else if (NETWORK_TO_MIGRATE_TO == "atlasnet"){
                
                admin                   = bob.pkh
                adminSk                 = bob.sk

                kycRegistrarSk          = bob.sk

                superAdminAddress       = contracts.atlasnet.superAdmin;
                kycAddress              = contracts.atlasnet.kyc;
                usdtTokenAddress        = contracts.atlasnet.usdt;
                debtControllerAddress   = contracts.atlasnet.debtController

            } else if (NETWORK_TO_MIGRATE_TO == "development"){
                
                admin                   = bob.pkh
                adminSk                 = bob.sk

                kycRegistrarSk          = bob.sk

                superAdminAddress       = contracts.local.superAdmin;
                kycAddress              = contracts.local.kyc;
                usdtTokenAddress        = contracts.local.usdt;
                debtControllerAddress   = contracts.local.debtController

            }

            //----------------------------
            // Input Params for interaction: 
            //
            //   1) New Debt Parameters
            //----------------------------

            maxAmount             = MAV(10)
            interestRate          = 1000;     // 10%
            term                  = 9;        // 9 months
            walletAddress         = admin     // mv1 address
            minInvestmentAmount   = MAV(2)
            tokenURI              = "https://verseprop-byd6bdg5exfnayd3.z02.azurefd.net/static/raven.png"
            currency              = "mav"     // mav or usdc only

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


    it('create new debt', async () => {
        try {

            const tokenURIHex        = Buffer.from(tokenURI, 'ascii').toString('hex');

            debtControllerOperation = await debtControllerInstance.methods.createDebt(
                maxAmount,
                interestRate,
                term,
                walletAddress,
                minInvestmentAmount,
                tokenURIHex,
                currency
            ).send();
            await debtControllerOperation.confirmation();

        } catch (e) {
            console.log(e)
        }
    })


    it(`-- interaction complete --`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})