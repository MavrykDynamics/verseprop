import { MichelsonMap } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob, alice, eve, david } from '../scripts/sandbox/accounts'
import { superAdminStorageType } from "./storageTypes/superAdminStorageType"

const config = {
    threshold             : 0, 
    actionExpiryInSeconds : (86400 * 3) // 3 days
}

const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('tezos-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
        name: 'Super Admin Contract',
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

const signatoryLedger = MichelsonMap.fromLiteral({
    [bob.pkh] : null,
    [alice.pkh] : null,
    [david.pkh] : null,
});

export const superAdminStorage : superAdminStorageType = {

    signatoryLedger           : signatoryLedger,
    signatorySize             : new BigNumber(3),

    signatureLedger           : MichelsonMap.fromLiteral({}),
    signatoryActionLedger     : MichelsonMap.fromLiteral({}),
    actionCounter             : new BigNumber(0),

    generalAdminLedger        : MichelsonMap.fromLiteral({}),
    contractAdminLedger       : MichelsonMap.fromLiteral({}),

    metadata                  : metadata,
    config                    : config,

    lambdaLedger              : MichelsonMap.fromLiteral({})
};
