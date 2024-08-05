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

import { GeneralContract, setGeneralContractLambdas }  from '../helpers/deploymentTestHelper'
import { bob } from '../../scripts/sandbox/accounts'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------

import { debtControllerStorage } from '../../storage/debtControllerStorage'
import {
    signerFactory,
} from '../helpers/helperFunctions'


// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Debt Controller', async () => {
    
    var utils: Utils
    var debtController 
    var tezos

    before('setup', async () => {
        try{

            utils = new Utils()
            await utils.init(bob.sk)
        
            //----------------------------
            // Originate and deploy contracts
            //----------------------------
        
            debtControllerStorage.kycAddress = contractDeployments.kyc.address;
            debtController = await GeneralContract.originate(utils.tezos, "debtController", debtControllerStorage)
            await saveContractAddress('debtControllerAddress', debtController.contract.address)

            tezos = debtController.tezos
            await signerFactory(tezos, bob.sk)

            // Set Lambdas
            await setGeneralContractLambdas(tezos, "debtController", debtController.contract)
        
        } catch(e){
            console.dir(e, {depth: 5})
        }

    })

    it(`debtController contract deployed`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})