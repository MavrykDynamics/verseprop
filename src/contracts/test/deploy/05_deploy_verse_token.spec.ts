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

            const metadata = MichelsonMap.fromLiteral({
                '': Buffer.from('mavryk-storage:data', 'ascii').toString('hex'),
                data: Buffer.from(
                    JSON.stringify({
                    name: 'VerseProp - Verse Prop Token (VP)',
                    version: 'v1.0.0',
                    authors: ['Mavryk Dynamics <info@mavryk.io>'],
                    homepage: "https://www.verseprop.com",
                    license: {
                        name: "MIT"
                    },
                    source: {
                        tools: [
                            "MavrykLIGO 0.60.0",
                            "Flexmasa atlas-update-run"
                        ],
                        location: "https://github.com/Mavryk-Dynamics/verseprop"
                    },
                    interfaces: [ 'MIP-12', 'MIP-16', 'MIP-21' ],
                    assets: [
                        {
                            symbol: Buffer.from('VP').toString('hex'),
                            name: Buffer.from('Verse Prop').toString('hex'),
                            decimals: Buffer.from('3').toString('hex'),
                            icon: Buffer.from('ipfs://QmQnxPFH9fjBByZ6YEj6RW31W3Zz1CqG9YsGBKzgKGApya').toString('hex'),
                            shouldPreferSymbol: '74727565',
                            thumbnailUri: Buffer.from('ipfs://QmQnxPFH9fjBByZ6YEj6RW31W3Zz1CqG9YsGBKzgKGApya').toString('hex'),
                            subheader: Buffer.from('Financial Asset v2').toString('hex'),
                            description: Buffer.from('A fractional investment in a single residential loan. Investors can purchase individual units, which provides a more accessible way to invest, spreading both the investment and potential returns across all unit holders.').toString('hex'),
                            info: {
                                "capital diversification": Buffer.from("This opportunity offers fractional investment in a single residential loan. Investors can purchase individual units, which provides a more accessible way to invest, spreading both the investment and potential returns across all unit holders.").toString('hex'),
                                "full recourse": Buffer.from("Investors acquire shares in a Special Purpose Vehicle (SPV) that holds direct recourse to the asset, secured by a registered charge on the Land Registry Title.").toString('hex'),
                                "first charge loan": Buffer.from("Secured against the asset and overcollateralized, ensuring robust investor protection and reduced risk by providing tangible, verifiable assets that exceed the value of the loan.").toString('hex'),
                                "the asset": Buffer.from("The residential property is situated in the Home Counties that surrounds London and sits adjacent to a major transport link with direct access to Central London. Journey time approximately 30 minutes. The property is fully leased to private tenants with a rent guarantee from a local Government alongside an insurance policy. There is also a comprehensive service management solution in place.").toString('hex')
                            }
                        }
                    ]
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