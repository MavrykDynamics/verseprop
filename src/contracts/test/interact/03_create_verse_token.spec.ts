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

            // prepare storage

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
                                icon: Buffer.from('ipfs://Qmdou4n4HM5g5EFtRcyN5E5Np824rm3drtUzieiQz9TrN6').toString('hex'),
                                shouldPreferSymbol: '74727565',
                                thumbnailUri: Buffer.from('ipfs://Qmdou4n4HM5g5EFtRcyN5E5Np824rm3drtUzieiQz9TrN6').toString('hex'),
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