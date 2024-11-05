import { MichelsonMap } from "@mavrykdynamics/taquito-michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob, eve } from '../scripts/sandbox/accounts'
import { debtControllerStorageType } from "./storageTypes/debtControllerStorageType"


const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('mavryk-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
            name: 'VerseProp - Debt Controller',
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

export const debtControllerStorage : debtControllerStorageType = {
    
    admins                    : [bob.pkh],
    managers                  : [eve.pkh],

    superAdmin                : eve.pkh,
    newSuperAdmin             : null,
    kycAddress                : eve.pkh,

    feeWallet                 : eve.pkh,
    usdcTokenAddress          : eve.pkh,

    metadata                  : metadata,
    
    debtCount                 : new BigNumber(0),
    debtLedger                : MichelsonMap.fromLiteral({}),
    investmentLedger          : MichelsonMap.fromLiteral({}),

    tempMap                   : MichelsonMap.fromLiteral({}),

    lambdaLedger              : MichelsonMap.fromLiteral({})

};
