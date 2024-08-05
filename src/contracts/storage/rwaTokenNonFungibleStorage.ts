import { MichelsonMap } from "@taquito/michelson-encoder"
import { rwaTokenNonFungibleStorageType } from "./storageTypes/rwaTokenNonFungibleStorageType"
import { bob, eve, oscar } from '../scripts/sandbox/accounts'
import { zeroAddress } from "test/helpers/Utils";
import { BigNumber } from "bignumber.js"

export const rwaTokenNonFungibleStorage : rwaTokenNonFungibleStorageType = {
    
    superAdmin              : zeroAddress,
    newSuperAdmin           : null,

    kycAddress              : zeroAddress,
    isPaused                : false,

    metadata                : MichelsonMap.fromLiteral({}),

    token_metadata          : MichelsonMap.fromLiteral({}),
    total_supply            : new BigNumber(0),

    userChunkLedger         : MichelsonMap.fromLiteral({}),
    snapshotLedger          : MichelsonMap.fromLiteral({}),

    ledger                  : MichelsonMap.fromLiteral({}),
    ownerLedger             : MichelsonMap.fromLiteral({}),
    operators               : MichelsonMap.fromLiteral({}),
};
