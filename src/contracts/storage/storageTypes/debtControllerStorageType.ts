import { MichelsonMap, MichelsonMapKey } from "@taquito/michelson-encoder"
import { BigNumber } from "bignumber.js"

export type debtControllerStorageType = {

    admins                  : [string];   
    managers                : [string];   
    
    feeWallet               : string;
    usdcTokenAddress        : string;
    
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;

    debtCounter             : BigNumber;
    debtLedger              : MichelsonMap<MichelsonMapKey, unknown>;
    investmentLedger        : MichelsonMap<MichelsonMapKey, unknown>;

    lambdaLedger            : MichelsonMap<MichelsonMapKey, unknown>;

};
