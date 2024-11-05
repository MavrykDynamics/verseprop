import { MichelsonMap } from "@mavrykdynamics/taquito-michelson-encoder"
import { BigNumber } from "bignumber.js"
import { bob, eve } from '../scripts/sandbox/accounts'
import { kycStorageType } from "./storageTypes/kycStorageType"

const config = {
    minOfferAmount : 10, 
}

const breakGlassConfig = {
    setMemberIsPaused : false,
    freezeMemberIsPaused : false,
    unfreezeMemberIsPaused : false
}

const metadata = MichelsonMap.fromLiteral({
    '': Buffer.from('mavryk-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
            name: 'VerseProp - KYC',
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


export const kycStorage : kycStorageType = {

    superAdmin                  : bob.pkh,
    newSuperAdmin               : null,

    metadata                    : metadata,
    config                      : config,
    breakGlassConfig            : breakGlassConfig,

    whitelistLedger             : MichelsonMap.fromLiteral({}),
    blacklistLedger             : MichelsonMap.fromLiteral({}),
    
    validInputLedger            : MichelsonMap.fromLiteral({}),

    kycRegistrarLedger          : MichelsonMap.fromLiteral({}),
    countryTransferRuleLedger   : MichelsonMap.fromLiteral({}),
    memberLedger                : MichelsonMap.fromLiteral({}),

    lambdaLedger                : MichelsonMap.fromLiteral({})
    
};
