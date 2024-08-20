// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type totalSupplyType is big_map(nat, nat);

type tokenMetadataInfoType is record [
    token_id          : tokenIdType;
    token_info        : map(string, bytes);
]

type ledgerKeyType is [@layout:comb] record [
    owner           : address;
    token_id        : nat;
]
type ledgerType is big_map(ledgerKeyType, nat);

type ownerLedgerType is big_map(tokenIdType, ownerType)

type tokenMetadataType is big_map(tokenIdType, tokenMetadataInfoType);

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type reissueType is [@layout:comb] record [
    _to       : address;
    tokenId   : tokenIdType;
    tokenURI  : bytes;
]

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------

type verseTokenStorageType is [@layout:comb] record [
    
    admin                   : address;
    metadata                : metadataType;

    _maxSupply              : nat;
    _percentageInterest     : nat;
    _description            : string;
    _location               : string;
    _value                  : string;
    _other                  : string;
    _baseTokenURI           : bytes;

    whitelistContracts      : whitelistContractsType;   // whitelist of contracts that can access mint / onStakeChange entrypoints - doorman / vesting contract
    
    token_metadata          : tokenMetadataType;
    total_supply            : totalSupplyType;

    ledger                  : ledgerType;
    ownerLedger             : ownerLedgerType;

    nextTokenId             : nat;
]