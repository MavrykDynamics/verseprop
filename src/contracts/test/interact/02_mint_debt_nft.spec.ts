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
    updateOperators
} from '../helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Interact: Mint Debt NFT', async () => {
  
    var utils: Utils
    var tezos

    let recipient, tokenURI, nextTokenId

    let superAdminAddress, kycAddress, debtControllerAddress, usdtTokenAddress, debtNFTAddress

    let superAdminInstance, superAdminStorage
    let kycInstance, kycStorage
    let debtControllerInstance, debtControllerStorage
    let debtNFTInstance, debtNFTStorage
    let admin, adminSk, kycRegistrarSk

    let debtNFTOperation

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
            // Set signer to admin
            //----------------------------

            utils = new Utils()
            await utils.init(adminSk)
            tezos = utils.tezos

            await signerFactory(tezos, adminSk);

            //----------------------------
            // Input Params for interaction: 
            //
            //   1) Debt NFT KT1 address (from debt created)
            //   2) Receipient mv1 address
            //   3) Token URI string
            //----------------------------

            debtNFTAddress  = "KT1N7JRJoEAXmP4AygJtNEaArCkfyAqxRuRa"
            debtNFTInstance = await utils.tezos.contract.at(debtNFTAddress)

            recipient       = admin
            tokenURI        = "https://verseprop-byd6bdg5exfnayd3.z02.azurefd.net/static/raven.png"

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


    it('mint debt NFT to specified user', async () => {
        try {

            const tokenURIHex = Buffer.from(tokenURI, 'ascii').toString('hex');
            
            nextTokenId = await debtNFTInstance.contractViews.next_token_id().executeView({ viewCaller : admin});

            debtNFTOperation = await debtNFTInstance.methods.mint([
                {
                    token_metadata : tokenURIHex,
                    address : recipient 
                }
            ]).send();
            await debtNFTOperation.confirmation();

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