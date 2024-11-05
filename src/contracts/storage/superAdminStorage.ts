import { MichelsonMap } from "@mavrykdynamics/taquito-michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob, alice, eve, david } from '../scripts/sandbox/accounts'
import { superAdminStorageType } from "./storageTypes/superAdminStorageType"

const config = {
    threshold             : 0, 
    actionExpiryInSeconds : (86400 * 3) // 3 days
}

const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('mavryk-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
            name: 'VerseProp - Super Admin',
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
            interfaces: [ 'MIP-16' ],
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
