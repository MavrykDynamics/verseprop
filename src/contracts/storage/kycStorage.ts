import { MichelsonMap } from "@taquito/michelson-encoder"
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
    '': Buffer.from('tezos-storage:data', 'ascii').toString('hex'),
    data: Buffer.from(
        JSON.stringify({
        name: 'KYC Contract',
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
