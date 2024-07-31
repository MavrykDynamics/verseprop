// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type actionIdType is nat
type dataMapType is map(string, bytes);

type generalAdminLedgerType is big_map(address, unit)
type contractAdminLedgerType is big_map((address * address), unit) // contract address * admin address

type signatoryLedgerType is big_map(address, unit)

type signatureLedgerType is big_map((address * nat), unit)

type superAdminConfigType is [@layout:comb] record [
    threshold               : nat;
    actionExpiryInSeconds   : nat;            
];

type signatoryActionRecordType is [@layout:comb] record[
    
    initiator                       : address;          // address of action initiator
    actionType                      : string;           // 
    executed                        : bool;             // boolean of whether action has been executed

    status                          : string;           // PENDING / FLUSHED / EXECUTED 
    signersCount                    : nat;              // total number of signers

    dataMap                         : dataMapType;

    startDateTime                   : timestamp;        // timestamp of when action was initiated
    startLevel                      : nat;              // block level of when action was initiated
    executedDateTime                : option(timestamp);// timestamp of when action was executed
    executedLevel                   : option(nat);      // block level of when action was executed
    expirationDateTime              : timestamp;        // timestamp of when action will expire
]
type signatoryActionLedgerType is big_map(nat, signatoryActionRecordType)

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type setTokenKycActionType is [@layout:comb] record [
    kycAddress              : address;
    contractAddressList     : list(address);
]

type setContractAdminActionType is [@layout:comb] record [
    adminAddress            : address;
    contractAddressList     : list(address);
]

type setSuperAdminActionType is [@layout:comb] record [
    superAdminAddress       : address;
    contractAddressList     : list(address);
]


// type superAdminUpdateConfigNewValueType is nat
// type superAdminUpdateConfigActionType is 
//         ConfigThreshold                       of unit
//     |   ConfigActionExpiryDays                of unit

// type superAdminUpdateConfigParamsType is [@layout:comb] record [
//     updateConfigNewValue        : superAdminUpdateConfigNewValueType; 
//     updateConfigAction          : superAdminUpdateConfigActionType;
// ]

type superAdminUpdateConfigParamsType is [@layout:comb] record [
    configNewValue  : nat;
    configAction    : string;
]


type superAdminTransferActionType is [@layout:comb] record [
    contractAddress             : address;       // contract address (e.g. treasury address)
    receiverAddress             : address;       // receiver address
    tokenContractAddress        : address;       // token contract address
    tokenAmount                 : nat;           // token amount requested
    tokenType                   : string;        // "XTZ", "FA12", "FA2"
    tokenId                     : nat;           // token id
]


// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------

type superAdminLambdaActionType is 

        // Contract SuperAdmin Lambdas
    |   LambdaSetSuperAdmin               of setSuperAdminActionType
    |   LambdaClaimSuperAdmin             of list(address)

        // Contract Admin Lambdas
    |   LambdaSetGeneralAdmin             of list(address)
    |   LambdaRemoveGeneralAdmin          of list(address)
    |   LambdaSetContractAdmin            of setContractAdminActionType
    |   LambdaRemoveContractAdmin         of setContractAdminActionType

        // Signatory Lambdas
    |   LambdaAddSignatory                of list(address)
    |   LambdaRemoveSignatory             of list(address)

        // Token Lambdas
    |   LambdaSetTokenKyc                 of setTokenKycActionType
    |   LambdaKillToken                   of list(address)

        // Treasury Transfer Entrypoints
    |   LambdaTransfer                    of superAdminTransferActionType

        // Housekeeping Lambdas
    |   LambdaUpdateMetadata              of updateMetadataType
    |   LambdaUpdateConfig                of superAdminUpdateConfigParamsType
    |   LambdaMistakenTransfer            of transferActionType

        // Signatory Lambdas
    |   LambdaFlushAction                 of list(nat)
    |   LambdaSignAction                  of list(nat)

        // Set Lambda
    |   LambdaSetLambda                  of setLambdaType

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------

type superAdminStorageType is [@layout:comb] record [
    
    signatoryLedger           : signatoryLedgerType;
    signatorySize             : nat;

    signatureLedger           : signatureLedgerType;
    signatoryActionLedger     : signatoryActionLedgerType;
    actionCounter             : nat;
    
    generalAdminLedger        : generalAdminLedgerType;    // access to all (RWA Token) contracts linked to superAdmin
    contractAdminLedger       : contractAdminLedgerType;   // mapping of individual user address to specific contracts 

    metadata                  : metadataType;
    config                    : superAdminConfigType;

    lambdaLedger              : lambdaLedgerType;
]

