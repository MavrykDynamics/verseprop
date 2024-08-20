import { Utils } from "../helpers/Utils"
const saveContractAddress = require("../helpers/saveContractAddress")
import { BigNumber } from "bignumber.js"
import { MichelsonMap } from "@mavrykdynamics/taquito-michelson-encoder"

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

import { verseTokenStorage } from '../../storage/verseTokenStorage'
import {
    signerFactory,
} from '../helpers/helperFunctions'


// ------------------------------------------------------------------------------
// Contract Deployment Start
// ------------------------------------------------------------------------------

describe('Verse Token', async () => {
    
    var utils: Utils
    var verseToken 
    var tezos

    before('setup', async () => {
        try{

            utils = new Utils()
            await utils.init(bob.sk)
        
            //----------------------------
            // Init Params
            //----------------------------

            const _maxSupply            = 12345;
            const _percentageInterest   = 100;
            
            const _description          = "description";
            const _location             = "location";
            const _value                = "value";
            const _other                = "other";

            const _baseTokenURI         = "baseTokenURI";

            const name                  = "name";
            const symbol                = "symbol";

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

            //----------------------------
            // Originate and deploy contracts
            //----------------------------

            verseTokenStorage._maxSupply            = new BigNumber(_maxSupply);
            verseTokenStorage._percentageInterest   = new BigNumber(_percentageInterest);
            
            verseTokenStorage._description          = _description
            verseTokenStorage._location             = _location
            verseTokenStorage._value                = _value
            verseTokenStorage._other                = _other
            
            verseTokenStorage._baseTokenURI         = Buffer.from(_baseTokenURI).toString('hex');

            verseTokenStorage.metadata              = metadata;

            verseToken = await GeneralContract.originate(utils.tezos, "verseToken", verseTokenStorage)
            await saveContractAddress('verseTokenAddress', verseToken.contract.address)

            tezos = verseToken.tezos
            await signerFactory(tezos, bob.sk)

        
        } catch(e){
            console.dir(e, {depth: 5})
        }

    })

    it(`verseToken contract deployed`, async () => {
        try {
            console.log('-- -- -- -- -- -- -- -- -- -- -- -- --')
        } catch (e) {
            console.log(e)
        }
    })
  
})