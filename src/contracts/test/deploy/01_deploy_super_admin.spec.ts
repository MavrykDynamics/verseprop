import { Utils } from "../helpers/Utils"
const saveContractAddress = require("../helpers/saveContractAddress")

const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
chai.should()

// ------------------------------------------------------------------------------
// Contract Address
// ------------------------------------------------------------------------------

import contractDeployments from '../contractDeployments.json'

// ------------------------------------------------------------------------------
// Contract Helpers
// ------------------------------------------------------------------------------

import { GeneralContract, setGeneralContractLambdas } from '../helpers/deploymentTestHelper'
import { bob } from '../../scripts/sandbox/accounts'
import * as helperFunctions from '../helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------

import { superAdminStorage } from '../../storage/superAdminStorage'

// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Super Admin', async () => {
  
    var utils: Utils
    var superAdmin
    var tezos

    before('setup', async () => {
        try{

            utils = new Utils()
            await utils.init(bob.sk)
        
            //----------------------------
            // Originate and deploy contracts
            //----------------------------
        
            superAdmin = await GeneralContract.originate(utils.tezos, "superAdmin", superAdminStorage);
            await saveContractAddress('superAdminAddress', superAdmin.contract.address)
        
            /* ---- ---- ---- ---- ---- */
        
            tezos = superAdmin.tezos
            await helperFunctions.signerFactory(tezos, bob.sk);

            // Set Lambdas
            // Note: signatory (bob) set in initial superAdmin storage in order to set contract lambas 
            await setGeneralContractLambdas(tezos, "superAdmin", superAdmin.contract)

        } catch(e){
            console.dir(e, {depth: 5})
        }

    })

    it(`marketplace contract deployment`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})