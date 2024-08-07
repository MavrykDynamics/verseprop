import { MichelsonMap, MichelsonMapKey } from "@mavrykdynamics/taquito-michelson-encoder"
import { BigNumber } from "bignumber.js"

export type debtControllerStorageType = {

    admins                  : [string];   
    managers                : [string];   

    superAdmin              : string,
    newSuperAdmin           : string | null,
    kycAddress              : string,
    
    feeWallet               : string;
    usdcTokenAddress        : string;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;

    debtCount               : BigNumber;
    debtLedger              : MichelsonMap<MichelsonMapKey, unknown>;
    investmentLedger        : MichelsonMap<MichelsonMapKey, unknown>;

    tempMap                 : MichelsonMap<MichelsonMapKey, unknown>;

    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
