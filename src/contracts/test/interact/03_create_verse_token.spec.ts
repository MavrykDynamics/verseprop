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

import { bob } from '../../scripts/sandbox/accounts.js'
import { GeneralContract } from '../helpers/deploymentTestHelper'
import { verseTokenStorage } from '../../storage/verseTokenStorage'
import { 
    signerFactory,
} from '../helpers/helperFunctions'

// ------------------------------------------------------------------------------
// Contract Storage
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Interact: Create Verse Token', async () => {
  
    var utils: Utils
    var tezos

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
            // Input Params for interaction: 
            //----------------------------

            const whitelistAddress      = admin;

            const _maxSupply            = 12345;
            const _percentageInterest   = 100;
            
            const _description          = "description";
            const _location             = "location";
            const _value                = "value";
            const _other                = "other";

            const _baseTokenURI         = "baseTokenURI";

            const name                  = "name";
            const symbol                = "symbol";

            // prepare storage

            const metadata = MichelsonMap.fromLiteral({
                '': Buffer.from('tezos-storage:data', 'ascii').toString('hex'),
                data: Buffer.from(
                    JSON.stringify({
                    name: name,
                    symbol: symbol,
                    version: 'v1.0.0',
                    authors: ['MAVRYK Dev Team <contact@mavryk.finance>'],
                    source: {
                        tools: ['Ligo', 'Flextesa'],
                        location: 'https://ligolang.org/',
                    },
                    }),
                    'ascii',
                ).toString('hex'),
            })

            verseTokenStorage._maxSupply            = new BigNumber(_maxSupply);
            verseTokenStorage._percentageInterest   = new BigNumber(_percentageInterest);
            
            verseTokenStorage._description          = _description
            verseTokenStorage._location             = _location
            verseTokenStorage._value                = _value
            verseTokenStorage._other                = _other
            
            verseTokenStorage._baseTokenURI         = Buffer.from(_baseTokenURI).toString('hex');

            verseTokenStorage.metadata              = metadata;

            verseTokenStorage.whitelistContracts    = MichelsonMap.fromLiteral({
                'admin' : whitelistAddress
            })


        } catch(e){
            console.dir(e, {depth: 5})
        }

    })


    it('create verse token', async () => {
        try {

            verseToken = await GeneralContract.originate(utils.tezos, "verseToken", verseTokenStorage)
            console.log(`verseToken contract deployed at ${verseToken.contract.address}`)

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