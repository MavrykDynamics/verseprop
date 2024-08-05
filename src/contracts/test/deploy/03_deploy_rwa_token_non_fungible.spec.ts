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

import { GeneralContract }  from '../helpers/deploymentTestHelper'
import { bob } from '../../scripts/sandbox/accounts'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------

import { rwaTokenNonFungibleStorage } from '../../storage/rwaTokenNonFungibleStorage'

// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('RWA Token (Non-Fungible)', async () => {
    
    var utils: Utils
    var rwaTokenNonFungible
    var ledgerKey

    before('setup', async () => {
        try{

            utils = new Utils()
            await utils.init(bob.sk)
        
            //----------------------------
            // Originate and deploy contracts
            //----------------------------
            rwaTokenNonFungibleStorage.superAdmin = contractDeployments.superAdmin.address;
            rwaTokenNonFungibleStorage.kycAddress = contractDeployments.kyc.address;

            rwaTokenNonFungible = await GeneralContract.originate(utils.tezos, "rwaTokenNonFungible", rwaTokenNonFungibleStorage);
            await saveContractAddress('rwaTokenNonFungibleAddress', rwaTokenNonFungible.contract.address)
        
        } catch(e){
            console.dir(e, {depth: 5})
        }

    })

    it(`rwa token contract deployed`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})