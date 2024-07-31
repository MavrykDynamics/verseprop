// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type kycBreakGlassConfigType is [@layout:comb] record [
    setMemberIsPaused         : bool;
    freezeMemberIsPaused      : bool;
    unfreezeMemberIsPaused    : bool;
]

type kycRegistrarRecordType is [@layout:comb] record [
    name                    : string;
    kycAdmins               : set(address);
    membersVerified         : nat; 
    createdAt               : timestamp;

    setMemberIsPaused       : bool;
    freezeMemberIsPaused    : bool;
    unfreezeMemberIsPaused  : bool;
]
type kycRegistrarLedgerType is big_map(address, kycRegistrarRecordType)

type countryTransferRuleRecordType is [@layout:comb] record [
    whitelistCountries  : set(string);
    blacklistCountries  : set(string);
    sendingFrozen       : bool;
    receivingFrozen     : bool;
]
type countryTransferRuleLedgerType is big_map(string, countryTransferRuleRecordType)

type memberRecordType is [@layout:comb] record [
    country         : string;
    region          : string;
    investorType    : string;
    
    expireAt        : timestamp;  // registrar/company to have permission over users to update expiry 
    frozen          : bool;       // registrar/company (and superadmin) to have permission over users they have verified 
    
    kycRegistrar    : address;    // registrar/company that verified the kyc of the user
]
type memberLedgerType is big_map(address, memberRecordType)

type whitelistLedgerType is big_map(address, unit)

type validInputLedgerType is big_map(string, set(string))

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type validationTransferType is record [
    from_       : address;
    to_         : address;
    token_id    : nat;
    amount      : nat;
]

type setWhitelistActionType is 
    |   AddToWhitelist      of list(address)
    |   RemoveFromWhitelist of list(address)

type setBlacklistActionType is 
    |   AddToBlacklist      of list(address)
    |   RemoveFromBlacklist of list(address)

type setValidInputActionType is 
    |   Country         of list(string)
    |   Region          of list(string)
    |   InvestorType    of list(string)

type updateType is 
    |   Update of unit
    |   Remove of unit

type updateCountrySetActionType is [@layout:comb] record [
    country     : string;
    updateType  : string;
    countrySet  : set(string);
]

type addNewCountryTransferRuleActionType is [@layout:comb] record [
    country             : string;
    whitelistCountries  : set(string);
    blacklistCountries  : set(string);
    sendingFrozen       : bool;
    receivingFrozen     : bool
]

type freezeActionType is [@layout:comb] record [
    country : string;
    freezeBool : bool;
]

type setCountryTransferRuleActionType is 
    |   AddNewCountryTransferRule   of list(addNewCountryTransferRuleActionType)
    |   UpdateWhitelistCountries    of list(updateCountrySetActionType) 
    |   UpdateBlacklistCountries    of list(updateCountrySetActionType) 
    |   FreezeSending               of list(freezeActionType)
    |   FreezeReceiving             of list(freezeActionType)


type setKycRegistrarActionType is [@layout:comb] record [
    name                    : string;
    kycRegistrarAddress     : address;
    kycAdminAddresses       : set(address);    
]

type pauseKycRegistrarType is [@layout:comb] record [
    kycRegistrarAddress     : address;    
    pauseBool               : bool;
    actionToPause           : string;
]
type pauseKycRegistrarActionType is list(pauseKycRegistrarType)


type kycPausableEntrypointType is
        SetMember             of bool
    |   FreezeMember          of bool
    |   UnfreezeMember        of bool
    
type kycTogglePauseEntrypointType is [@layout:comb] record [
    targetEntrypoint  : kycPausableEntrypointType;
    empty             : unit
];

type addMemberActionType is [@layout:comb] record [
    memberAddress   : address;
    country         : string;
    region          : string;
    investorType    : string;
]

type updateMemberActionType is [@layout:comb] record [
    memberAddress   : address;
    country         : option(string);
    region          : option(string);
    investorType    : option(string);
    expireAt        : option(timestamp);
]

type setMemberActionType is 
    |   AddMember               of list(addMemberActionType)
    |   UpdateMember            of list(updateMemberActionType)
    |   RemoveMember            of list(address)


type setRegistrarAdminType is [@layout:comb] record [
    updateType           : string;
    adminAddress         : address;
    kycRegistrarAddress  : address;
]
type setRegistrarAdminActionType is list(setRegistrarAdminType)


// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------

type kycLambdaActionType is 

        // SuperAdmin Lambdas
        LambdaSetSuperAdmin               of (address)
    |   LambdaClaimSuperAdmin             of (unit)

        // Admin Lambdas
    |   LambdaSetCountryTransferRule      of setCountryTransferRuleActionType
    |   LambdaSetKycRegistrar             of setKycRegistrarActionType
    |   LambdaPauseKycRegistrar           of pauseKycRegistrarActionType
    |   LambdaSetValidInput               of setValidInputActionType
    |   LambdaSetWhitelist                of setWhitelistActionType
    |   LambdaSetBlacklist                of setBlacklistActionType
    
        // Housekeeping Lambdas
    |   LambdaUpdateMetadata              of updateMetadataType
    |   LambdaMistakenTransfer            of transferActionType

        // Pause / Break Glass Lambdas
    |   LambdaPauseAll                    of (unit)
    |   LambdaUnpauseAll                  of (unit)
    |   LambdaTogglePauseEntrypoint       of kycTogglePauseEntrypointType

        // KYC Lambdas
    |   LambdaSetMember                   of setMemberActionType
    |   LambdaSetRegistrarAdmin           of setRegistrarAdminActionType
    |   LambdaFreezeMember                of list(address)
    |   LambdaUnfreezeMember              of list(address)

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------


type kycStorageType is [@layout:comb] record [
    
    superAdmin                  : address;
    newSuperAdmin               : option(address);

    metadata                    : metadataType;
    breakGlassConfig            : kycBreakGlassConfigType;

    whitelistLedger             : whitelistLedgerType;
    blacklistLedger             : whitelistLedgerType; // ledger is same as whitelist

    validInputLedger            : validInputLedgerType; 

    kycRegistrarLedger          : kycRegistrarLedgerType;
    countryTransferRuleLedger   : countryTransferRuleLedgerType;
    memberLedger                : memberLedgerType;

    lambdaLedger                : lambdaLedgerType;
]

