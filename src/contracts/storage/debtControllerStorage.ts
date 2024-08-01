import { MichelsonMap } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob, eve } from '../scripts/sandbox/accounts'
import { debtControllerStorageType } from "./storageTypes/debtControllerStorageType"


const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('tezos-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
        name: 'Debt Controller Contract',
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

export const debtControllerStorage : debtControllerStorageType = {
    
    admins                    : [eve.pkh],
    managers                  : [eve.pkh],

    superAdmin                : eve.pkh,
    newSuperAdmin             : null,
    kycAddress                : eve.pkh,

    feeWallet                 : eve.pkh,
    usdcTokenAddress          : eve.pkh,

    metadata                  : metadata,
    
    debtCounter               : new BigNumber(0),
    debtLedger                : MichelsonMap.fromLiteral({}),
    investmentLedger          : MichelsonMap.fromLiteral({}),

    lambdaLedger              : MichelsonMap.fromLiteral({})

};
