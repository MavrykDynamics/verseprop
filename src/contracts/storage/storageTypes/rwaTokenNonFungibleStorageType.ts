import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type rwaTokenNonFungibleStorageType = {

    superAdmin              : string;
    newSuperAdmin           : null;

    kycAddress              : string;
    isPaused                : boolean;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;

    token_metadata          : MichelsonMap<MichelsonMapKey, unknown>;
    total_supply            : BigNumber;

    userChunkLedger         : MichelsonMap<MichelsonMapKey, unknown>;
    snapshotLedger          : MichelsonMap<MichelsonMapKey, unknown>;

    ledger                  : MichelsonMap<MichelsonMapKey, unknown>;
    ownerLedger             : MichelsonMap<MichelsonMapKey, unknown>;
    operators               : MichelsonMap<MichelsonMapKey, unknown>;

};
