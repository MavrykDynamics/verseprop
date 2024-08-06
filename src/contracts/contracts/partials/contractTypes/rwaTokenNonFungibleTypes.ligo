// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type tokenIdType            is nat 
type tokenBalanceType       is nat
type snapshotTimestampType  is timestamp
type operatorType           is address;
type ownerType              is address;

type snapshotType           is (nat * timestamp)

// ------------------------------------------------------------------------------
// View Types
// ------------------------------------------------------------------------------

type viewBalanceAtTimestampType is [@layout:comb] record [
    tokenId         : nat;
    user            : address; 
    timestamp       : timestamp;
    startCounter    : option(nat);
    endCounter      : option(nat);
]

type viewUserSnapshotsType is [@layout:comb] record [
    tokenId         : nat;
    user            : address; 
    startCounter    : option(nat);
    endCounter      : option(nat);
]

// ------------------------------------------------------------------------------
// Ledger Types
// ------------------------------------------------------------------------------

type metadataType is big_map (string, bytes)

type operatorsType is big_map((ownerType * operatorType * tokenIdType), unit)

// token type is non-fungible 
type tokenMetadataType is [@layout:comb] record [
    token_id          : tokenIdType;
    token_info        : map(string, bytes);
]
type tokenMetadataLedgerType is big_map(tokenIdType, tokenMetadataType);

type totalSupplyType is big_map(nat, nat);


type ledgerKeyType is [@layout:comb] record [
    owner           : address;
    token_id        : nat;
]
type ledgerType is big_map(ledgerKeyType, nat);

type ownerLedgerType is big_map(tokenIdType, ownerType)

type snapshotMapChunkType is map(nat, nat * timestamp)                          // snapshot counter -> token balance, timestamp
type snapshotLedgerType is big_map(nat * address * nat, snapshotMapChunkType)   // token id * user address * chunk -> snapshot map chunk

type userChunkRecordType is [@layout:comb] record [
    chunkCounter : nat;
    snapshotCounter : nat;
]
type userChunkLedgerType is big_map(address, userChunkRecordType)

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type mintType is [@layout:comb] record [
    token_metadata  : bytes;
    address         : address; 
]

type burnType is [@layout:comb] record [
    token_id        : nat;
    address         : address; 
]

(* Balance_of entrypoint inputs *)
type balanceOfRequestType is [@layout:comb] record[
    owner       : ownerType;
    token_id    : tokenIdType;
]
type balanceOfResponse is [@layout:comb] record[
    request     : balanceOfRequestType;
    balance     : tokenBalanceType;
]
type balanceOfType is [@layout:comb] record[
    requests    : list(balanceOfRequestType);
    callback    : contract(list(balanceOfResponse));
]


type txType is [@layout:comb] record[
    to_       : address;
    token_id  : tokenIdType;
    amount    : tokenBalanceType;
]

type transferType is [@layout:comb] record[
    from_     : address;
    txs       : list(txType);
]

type fa2TransferType is list(transferType)


(* Update_operators entrypoint inputs *)
type operatorParameterType is [@layout:comb] record[
    owner       : ownerType;
    operator    : operatorType;
    token_id    : tokenIdType;
]
type updateOperatorVariantType is 
        Add_operator    of operatorParameterType
    |   Remove_operator of operatorParameterType
type updateOperatorsType is list(updateOperatorVariantType)


// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------

type rwaTokenStorageType is [@layout:comb] record [

    superAdmin              : address;
    newSuperAdmin           : option(address);

    kycAddress              : address;
    isPaused                : bool;

    metadata                : metadataType;

    token_metadata          : tokenMetadataLedgerType;
    total_supply            : totalSupplyType;

    userChunkLedger         : userChunkLedgerType;
    snapshotLedger          : snapshotLedgerType;

    ledger                  : ledgerType;
    ownerLedger             : ownerLedgerType;
    operators               : operatorsType;

    nextTokenId             : nat;
]
