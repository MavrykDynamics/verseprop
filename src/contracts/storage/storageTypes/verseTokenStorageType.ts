import { MichelsonMap, MichelsonMapKey } from "@mavrykdynamics/taquito-michelson-encoder"
import { BigNumber } from "bignumber.js"

export type verseTokenStorageType = {

    admin                   : string;
    metadata                : MichelsonMap<MichelsonMapKey, unknown>;

    _maxSupply              : BigNumber;
    _percentageInterest     : BigNumber;
    _description            : string;
    _location               : string;
    _value                  : string;
    _other                  : string;
    _baseTokenURI           : string;

    whitelistContracts      : MichelsonMap<MichelsonMapKey, unknown>;

    token_metadata          : MichelsonMap<MichelsonMapKey, unknown>;
    total_supply            : MichelsonMap<MichelsonMapKey, unknown>;

    ledger                  : MichelsonMap<MichelsonMapKey, unknown>;
    ownerLedger             : MichelsonMap<MichelsonMapKey, unknown>;

    nextTokenId             : BigNumber;

};
