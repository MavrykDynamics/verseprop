import { MichelsonMap } from "@mavrykdynamics/taquito-michelson-encoder"
import { BigNumber } from "bignumber.js"
import { Buffer } from "buffer"
import { zeroAddress } from "../test/helpers/Utils"
import { bob, alice, eve, mallory, david, oscar } from '../scripts/sandbox/accounts'
import { mavrykFa2TokenStorageType } from "./storageTypes/mavrykFa2TokenStorageType"

const totalSupply      = 18000000000;
const initialSupply    = new BigNumber(totalSupply); // 20,000 MOCK FA2 Tokens in mu (10^6)
const singleUserSupply = new BigNumber(totalSupply / 6);

const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('mavryk-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
        name: 'VerseProp - Mock FA2',
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
                symbol: Buffer.from('FA2').toString('hex'),
                name: Buffer.from('VerseProp Mock FA2').toString('hex'),
                decimals: Buffer.from('6').toString('hex'),
                icon: Buffer.from('ipfs://QmZR4FJ4ATgZ1DWRU8Afa5ECAkzRVQumuJd4Bft5iajs73').toString('hex'),
                shouldPreferSymbol: '74727565',
                thumbnailUri: Buffer.from('ipfs://QmZR4FJ4ATgZ1DWRU8Afa5ECAkzRVQumuJd4Bft5iajs73').toString('hex')
            }
        ]
        }),
        'ascii',
    ).toString('hex'),
})

const ledger = MichelsonMap.fromLiteral({
    [bob.pkh]: singleUserSupply,
    [alice.pkh]: singleUserSupply,
    [eve.pkh]: singleUserSupply,
    [mallory.pkh]: singleUserSupply,
    [david.pkh]: singleUserSupply,
    [oscar.pkh]: singleUserSupply,
})

const token_metadata = MichelsonMap.fromLiteral({
    0: {
        token_id: '0',
        token_info: MichelsonMap.fromLiteral({
            symbol: Buffer.from('FA2').toString('hex'),
            name: Buffer.from('VerseProp Mock FA2').toString('hex'),
            decimals: Buffer.from('6').toString('hex'),
            icon: Buffer.from('ipfs://QmZR4FJ4ATgZ1DWRU8Afa5ECAkzRVQumuJd4Bft5iajs73').toString('hex'),
            shouldPreferSymbol: '74727565',
            thumbnailUri: Buffer.from('ipfs://QmZR4FJ4ATgZ1DWRU8Afa5ECAkzRVQumuJd4Bft5iajs73').toString('hex')
        }),
    },
})

export const mavrykFa2TokenStorage: mavrykFa2TokenStorageType = {
    
    admin: bob.pkh,
    metadata: metadata,
    governanceAddress: zeroAddress,

    whitelistContracts:  MichelsonMap.fromLiteral({}),

    token_metadata: token_metadata,
    totalSupply: initialSupply,
    ledger: ledger,
    operators:  MichelsonMap.fromLiteral({})

};
