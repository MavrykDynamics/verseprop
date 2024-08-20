import { Utils } from "../helpers/Utils"
import { MichelsonMap } from "@mavrykdynamics/taquito-michelson-encoder"
import { BigNumber } from "bignumber.js"

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

import { bob, eve, alice } from '../../scripts/sandbox/accounts.js'
import { GeneralContract } from '../helpers/deploymentTestHelper.js'
import { verseTokenStorage } from '../../storage/verseTokenStorage.js'
import { 
    signerFactory,
} from '../helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Interact: Mint Verse Token', async () => {
  
    var utils: Utils
    var tezos

    let receiverAddress, verseTokenContractAddress
    let verseTokenInstance, verseTokenInstanceStorage

    let verseToken
    let admin, adminSk

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

            } else if (NETWORK_TO_MIGRATE_TO == "atlasnet"){
                
                admin                   = bob.pkh
                adminSk                 = bob.sk

            } else if (NETWORK_TO_MIGRATE_TO == "development"){
                
                admin                   = bob.pkh
                adminSk                 = bob.sk

            }

            //----------------------------
            // Set signer to admin
            //----------------------------

            utils = new Utils()
            await utils.init(adminSk)
            tezos = utils.tezos

            await signerFactory(tezos, adminSk);

            //----------------------------
            //  Input Params for interaction: 
            //----------------------------

            verseTokenContractAddress       = "KT1UtEzF6d7UXcqt3gLtVLE2ukFjDBpcuGv4"
            receiverAddress                 = alice.pkh

            verseTokenInstance              = await utils.tezos.contract.at(verseTokenContractAddress)
            verseTokenInstanceStorage       = await verseTokenInstance.storage()


        } catch(e){
            console.dir(e, {depth: 5})
        }

    })


    it('mint verse token', async () => {
        try {

            const mintOperation = await verseTokenInstance.methods.mint(receiverAddress).send();
            await mintOperation.confirmation();

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