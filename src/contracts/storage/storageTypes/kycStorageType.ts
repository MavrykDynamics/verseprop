import { MichelsonMap, MichelsonMapKey } from "@mavrykdynamics/taquito-michelson-encoder"
import { BigNumber } from "bignumber.js"

export type kycStorageType = {
    
    superAdmin                  : string;
    newSuperAdmin               : string | null;

    metadata                    : MichelsonMap<MichelsonMapKey, unknown>;
    config                      : {};
    breakGlassConfig            : {};

    whitelistLedger             : MichelsonMap<MichelsonMapKey, unknown>;
    blacklistLedger             : MichelsonMap<MichelsonMapKey, unknown>;

    validInputLedger            : MichelsonMap<MichelsonMapKey, unknown>;

    kycRegistrarLedger          : MichelsonMap<MichelsonMapKey, unknown>;
    countryTransferRuleLedger   : MichelsonMap<MichelsonMapKey, unknown>;
    memberLedger                : MichelsonMap<MichelsonMapKey, unknown>;
    
    lambdaLedger                : MichelsonMap<MichelsonMapKey, unknown>;
};
