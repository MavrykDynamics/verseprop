import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type superAdminStorageType = {
    
    signatoryLedger         : MichelsonMap<MichelsonMapKey, unknown>;
    signatorySize           : BigNumber;

    signatureLedger         : MichelsonMap<MichelsonMapKey, unknown>;
    signatoryActionLedger   : MichelsonMap<MichelsonMapKey, unknown>;
    actionCounter           : BigNumber;

    generalAdminLedger      : MichelsonMap<MichelsonMapKey, unknown>;
    contractAdminLedger     : MichelsonMap<MichelsonMapKey, unknown>;

    metadata                : MichelsonMap<MichelsonMapKey, unknown>;
    config                  : {};
    
    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
