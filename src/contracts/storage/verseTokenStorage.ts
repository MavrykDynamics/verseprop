import { MichelsonMap } from "@mavrykdynamics/taquito-michelson-encoder"
import { verseTokenStorageType } from "./storageTypes/verseTokenStorageType"
import { bob, eve, oscar } from '../scripts/sandbox/accounts'
import { zeroAddress } from "test/helpers/Utils";
import { BigNumber } from "bignumber.js"

export const verseTokenStorage : verseTokenStorageType = {
    
    admin                   : bob.pkh,
    metadata                : MichelsonMap.fromLiteral({}),

    _maxSupply              : new BigNumber(0),
    _percentageInterest     : new BigNumber(0),
    _description            : "",
    _location               : "",
    _value                  : "",
    _other                  : "",
    _baseTokenURI           : "",

    whitelistContracts      : MichelsonMap.fromLiteral({}),

    token_metadata          : MichelsonMap.fromLiteral({}),
    total_supply            : MichelsonMap.fromLiteral({}),

    ledger                  : MichelsonMap.fromLiteral({}),
    ownerLedger             : MichelsonMap.fromLiteral({}),

    nextTokenId             : new BigNumber(0),
};
