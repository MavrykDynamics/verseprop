// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------

// Allowed Senders: Signatory address
function verifySenderIsSignatory(var s : superAdminStorageType) : unit is
block {

    if Big_map.mem(Tezos.get_sender(), s.signatoryLedger) then skip
    else failwith(error_ONLY_SIGNATORIES_ALLOWED);

} with unit
    

// Allowed Senders: General Admin
function verifySenderIsGeneralAdmin(var s : superAdminStorageType) : unit is
block {

    if Big_map.mem(Tezos.get_sender(), s.generalAdminLedger) then skip
    else failwith(error_ONLY_GENERAL_ADMIN_ALLOWED);

} with unit


// Allowed Senders: Contract Admin
function verifySenderIsContractAdmin(var s : superAdminStorageType) : unit is
block {

    if Big_map.mem((Tezos.get_sender(), Tezos.get_self_address()), s.contractAdminLedger) then skip
    else failwith(error_ONLY_CONTRACT_ADMIN_ALLOWED);

} with unit


// Allowed Senders: Self
function verifySenderIsSelf(const _p : unit) : unit is
block {

    if Tezos.get_sender() = Tezos.get_self_address() then skip
    else failwith(error_ONLY_SELF_ADDRESS_ALLOWED);

} with unit
    
    
// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Entrypoint Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to %setSuperAdmin entrypoint on specified contract
function sendSetSuperAdminParams(const contractAddress : address) : contract(address) is
    case (Tezos.get_entrypoint_opt(
        "%setSuperAdmin",
        contractAddress) : option(contract(address))) of [
                Some(contr) -> contr
            |   None        -> (failwith(error_SET_SUPER_ADMIN_ENTRYPOINT_IN_CONTRACT_NOT_FOUND) : contract(address))
        ];



// helper function to %claimSuperAdmin entrypoint on specified contract
function sendClaimSuperAdminParams(const contractAddress : address) : contract(unit) is
    case (Tezos.get_entrypoint_opt(
        "%claimSuperAdmin",
        contractAddress) : option(contract(unit))) of [
                Some(contr) -> contr
            |   None        -> (failwith(error_CLAIM_SUPER_ADMIN_ENTRYPOINT_IN_CONTRACT_NOT_FOUND) : contract(unit))
        ];


// helper function to %setTokenKyc entrypoint on specified contract
function sendSetTokenKycParams(const contractAddress : address) : contract(address) is
    case (Tezos.get_entrypoint_opt(
        "%setTokenKyc",
        contractAddress) : option(contract(address))) of [
                Some(contr) -> contr
            |   None        -> (failwith(error_SET_TOKEN_KYC_ENTRYPOINT_IN_CONTRACT_NOT_FOUND) : contract(address))
        ];


// helper function to %killToken entrypoint on specified contract
function sendKillTokenParams(const contractAddress : address) : contract(unit) is
    case (Tezos.get_entrypoint_opt(
        "%kill",
        contractAddress) : option(contract(unit))) of [
                Some(contr) -> contr
            |   None        -> (failwith(error_KILL_ENTRYPOINT_IN_CONTRACT_NOT_FOUND) : contract(unit))
        ];



// helper function to %transfer entrypoint on specified contract
function sendTransferParams(const contractAddress : address) : contract(transferActionType) is
    case (Tezos.get_entrypoint_opt(
        "%transfer",
        contractAddress) : option(contract(transferActionType))) of [
                Some(contr) -> contr
            |   None        -> (failwith(error_TRANSFER_ENTRYPOINT_IN_CONTRACT_NOT_FOUND) : contract(transferActionType))
        ];

// ------------------------------------------------------------------------------
// Entrypoint Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// General Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to get a signatory action record
function getSignatoryActionRecord(const signatoryActionId : nat; const s : superAdminStorageType) : signatoryActionRecordType is
block {

    const signatoryActionRecord : signatoryActionRecordType = case Big_map.find_opt(signatoryActionId, s.signatoryActionLedger) of [
            Some (_action) -> _action
        |   None           -> failwith(error_SIGNATORY_ACTION_NOT_FOUND)
    ];

} with signatoryActionRecord



// helper function to check if signatory can interact with an action
function validateAction(const actionRecord : signatoryActionRecordType) : unit is
block {

    // Check if signatory action has been flushed
    if actionRecord.status = "FLUSHED" then failwith(error_SIGNATORY_ACTION_FLUSHED)  else skip;

    // Check if signatory action has already been executed
    if actionRecord.executed then failwith(error_SIGNATORY_ACTION_EXECUTED) else skip;

    // check that signatory action has not expired
    if Tezos.get_now() > actionRecord.expirationDateTime then failwith(error_SIGNATORY_ACTION_EXPIRED) else skip;

} with (unit)



// helper function to check if signatory can interact with an action (not flushed / executed / expired)
function validateActionById(const signatoryActionId : nat; const s : superAdminStorageType) : unit is
block {

    const actionRecord : signatoryActionRecordType = getSignatoryActionRecord(signatoryActionId, s);

    // Check if signatory action has been flushed
    if actionRecord.status = "FLUSHED" then failwith(error_SIGNATORY_ACTION_FLUSHED)  else skip;

    // Check if signatory action has already been executed
    if actionRecord.executed then failwith(error_SIGNATORY_ACTION_EXECUTED) else skip;

    // check that signatory action has not expired
    if Tezos.get_now() > actionRecord.expirationDateTime then failwith(error_SIGNATORY_ACTION_EXPIRED) else skip;

} with (unit)



// helper to create a signatory action
function createSignatoryAction(const actionType : string; const dataMap : dataMapType; var s : superAdminStorageType) : superAdminStorageType is 
block {

    const signatoryActionRecord : signatoryActionRecordType = record[
        initiator             = Tezos.get_sender();
        actionType            = actionType;
        executed              = False;

        status                = "PENDING";
        signersCount          = 0n;
        
        dataMap               = dataMap;

        startDateTime         = Tezos.get_now();
        startLevel            = Tezos.get_level();             
        executedDateTime      = None;
        executedLevel         = None;
        expirationDateTime    = Tezos.get_now() + int(s.config.actionExpiryInSeconds);
    ];
    
    s.signatoryActionLedger[s.actionCounter] := signatoryActionRecord;

    // increment action counter
    s.actionCounter := s.actionCounter + 1n;

} with(s)



// helper function to verify that signatory exists
function verifySignatoryExists(const signatoryAddress : address; const  s : superAdminStorageType) : unit is 
block {

    if not Big_map.mem(signatoryAddress, s.signatoryLedger) then failwith(error_SIGNATORY_NOT_FOUND)
    else skip;

} with unit



// helper function to verify that signatory does not exist
function verifySignatoryDoesNotExist(const signatoryAddress : address; const  s : superAdminStorageType) : unit is 
block {

    if Big_map.mem(signatoryAddress, s.signatoryLedger) then failwith(error_SIGNATORY_ALREADY_EXISTS)
    else skip;

} with unit



// helper function to verify that signatory threshold is valid and will not be below config threshold
function verifyValidSignatoryThreshold(const  s : superAdminStorageType) : unit is 
block {

    if (abs(s.signatorySize - 1n)) < s.config.threshold then failwith(error_SIGNATORY_THRESHOLD_ERROR)
    else skip;

} with unit



// helper function to verify that signatory action exists
function verifySignatoryActionExists(const signatoryActionId : nat; const s : superAdminStorageType) : unit is 
block {

    const _signatoryActionRecord : signatoryActionRecordType = getSignatoryActionRecord(signatoryActionId, s);

} with unit



// helper function to verify token type is correct
function verifyCorrectTokenType(const tokenType : string) : unit is 
block {

    if  tokenType = "FA12" or
        tokenType = "FA2"  or
        tokenType = "TEZ" then skip
    else failwith(error_WRONG_TOKEN_TYPE_PROVIDED);

} with unit



// helper function to unpack strings from dataMap
function unpackString(const actionRecord : signatoryActionRecordType; const key : string) : string is 
block {

    const unpackedString : string = case actionRecord.dataMap[key] of [
            Some(_string) -> case (Bytes.unpack(_string) : option(string)) of [
                    Some (_v)   -> _v
                |   None        -> failwith(error_UNABLE_TO_UNPACK_ACTION_PARAMETER)
            ]
        |   None -> failwith(error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND)
    ];

} with unpackedString



// helper function to unpack address from dataMap
function unpackAddress(const actionRecord : signatoryActionRecordType; const key : string) : address is 
block {

    const unpackedAddress : address = case actionRecord.dataMap[key] of [
            Some(_address) -> case (Bytes.unpack(_address) : option(address)) of [
                    Some (_v)   -> _v
                |   None        -> failwith(error_UNABLE_TO_UNPACK_ACTION_PARAMETER)
            ]
        |   None -> failwith(error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND)
    ];

} with unpackedAddress



// helper function to unpack nat from dataMap
function unpackNat(const actionRecord : signatoryActionRecordType; const key : string) : nat is 
block {

    const unpackedNat : nat = case actionRecord.dataMap[key] of [
            Some(_nat) -> case (Bytes.unpack(_nat) : option(nat)) of [
                    Some (_v)   -> _v
                |   None        -> failwith(error_UNABLE_TO_UNPACK_ACTION_PARAMETER)
            ]
        |   None -> failwith(error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND)
    ];

} with unpackedNat



// helper function to unpack list(address) from dataMap
function unpackListAddress(const actionRecord : signatoryActionRecordType; const key : string) : list(address) is 
block {

    const unpackedListAddress : list(address) = case actionRecord.dataMap[key] of [
            Some(_list) -> case (Bytes.unpack(_list) : option(list(address))) of [
                    Some (_v)   -> _v
                |   None        -> failwith(error_UNABLE_TO_UNPACK_ACTION_PARAMETER)
            ]
        |   None -> failwith(error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND)
    ];

} with unpackedListAddress



// helper function to unpack list(nat) from dataMap
function unpackListNat(const actionRecord : signatoryActionRecordType; const key : string) : list(nat) is 
block {

    const unpackedListNat : list(nat) = case actionRecord.dataMap[key] of [
            Some(_list) -> case (Bytes.unpack(_list) : option(list(nat))) of [
                    Some (_v)   -> _v
                |   None        -> failwith(error_UNABLE_TO_UNPACK_ACTION_PARAMETER)
            ]
        |   None -> failwith(error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND)
    ];

} with unpackedListNat


// helper function to unpack option(key_hash) from dataMap
function unpackKeyHash(const actionRecord : signatoryActionRecordType; const key : string) : option(key_hash) is 
block {

    const unpackedKeyhash : option(key_hash) = case actionRecord.dataMap[key] of [
            Some(_keyHash) -> case (Bytes.unpack(_keyHash) : option(option(key_hash))) of [
                    Some (_v)   -> _v
                |   None        -> failwith(error_UNABLE_TO_UNPACK_ACTION_PARAMETER)
            ]
        |   None -> failwith(error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND)
    ];

} with unpackedKeyhash

// ------------------------------------------------------------------------------
// General Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Operations Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function for setSuperAdmin
function setSuperAdminOperation(const superAdminAddress : address; const contractAddress : address) : operation is 
block {

    const setSuperAdminOperation : operation = Tezos.transaction(
        superAdminAddress,
        0tez, 
        sendSetSuperAdminParams(contractAddress)
    );

} with setSuperAdminOperation



// helper function for claimSuperAdmin
function claimSuperAdminOperation(const contractAddress : address) : operation is 
block {

    const claimSuperAdminOperation : operation = Tezos.transaction(
        unit,
        0tez, 
        sendClaimSuperAdminParams(contractAddress)
    );

} with claimSuperAdminOperation



// helper function for setTokenKyc
function setTokenKycOperation(const kycAddress : address; const contractAddress : address) : operation is 
block {

    const setTokenKycOperation : operation = Tezos.transaction(
        (kycAddress),
        0tez, 
        sendSetTokenKycParams(contractAddress)
    );

} with setTokenKycOperation



// helper function for killToken
function killTokenOperation(const tokenAddress : address) : operation is 
block {

    const killTokenOperation : operation = Tezos.transaction(
        unit,
        0tez, 
        sendKillTokenParams(tokenAddress)
    );

} with killTokenOperation



// helper function for createTransferOperation
function createTransferOperation(const contractAddress : address; const receiverAddress : address; const amount : nat; const token : tokenType) : operation is 
block {

    const transferDestinationRecord : transferDestinationType = record [
        to_     = receiverAddress;
        amount  = amount;
        token   = token;
    ];

    const transferActionParams : transferActionType = list[transferDestinationRecord];

    const transferOperation : operation = Tezos.transaction(
        transferActionParams,
        0tez, 
        sendTransferParams(contractAddress)
    );

} with transferOperation

// ------------------------------------------------------------------------------
// Operations Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Verify Entrypoint Helper Functions Begin
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Verify Entrypoint Helper Functions End
// ------------------------------------------------------------------------------




// ------------------------------------------------------------------------------
// Sign Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to trigger the set general admin action during the signing
function triggerSetGeneralAdminAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is 
block {

    // fetch params begin ---
    const generalAdminAddressList : list(address) = unpackListAddress(actionRecord, "generalAdminAddressList");
    // fetch params end ---

    // loop over general admin address list
    for generalAdminAddress in list generalAdminAddressList block {

        // verify address is not already general admin
        case s.generalAdminLedger[generalAdminAddress] of [
                Some(_v) -> failwith(error_ADDRESS_IS_ALREADY_GENERAL_ADMIN)
            |   None     -> skip
        ];

        // add new general admin
        s.generalAdminLedger[generalAdminAddress] := unit;

    };

} with (s)



// helper function to trigger the remove general admin action during the signing
function triggerRemoveGeneralAdminAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is 
block {

    // fetch params begin ---
    const generalAdminAddressList : list(address) = unpackListAddress(actionRecord, "generalAdminAddressList");
    // fetch params end ---

    // loop over general admin address list
    for generalAdminAddress in list generalAdminAddressList block {

        // verify address is not already general admin
        case s.generalAdminLedger[generalAdminAddress] of [
                Some(_v) -> skip
            |   None     -> failwith(error_ADDRESS_NOT_GENERAL_ADMIN)
        ];

        // remove general admin
        remove generalAdminAddress from map s.generalAdminLedger;

    };

} with (s)



// helper function to trigger the set contract admin action during the sign
function triggerSetContractAdminAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is
block {
    
    // fetch params begin ---
    const adminAddress  : address               = unpackAddress(actionRecord, "adminAddress");
    const contractAddressList  : list(address)  = unpackListAddress(actionRecord, "contractAddressList");
    // fetch params end ---

    // loop over ccontract address list
    for contractAddress in list contractAddressList block {

        const adminContractTuple : (address * address) = (adminAddress, contractAddress);

        // verify contract admin address does not exist
        case s.contractAdminLedger[adminContractTuple] of [
                Some(_v) -> failwith(error_ADDRESS_IS_ALREADY_CONTRACT_ADMIN)
            |   None     -> skip
        ];

        // add new contract admin
        s.contractAdminLedger[adminContractTuple] := unit;

    };

} with (s)



// helper function to trigger the remove contract admin action during the sign
function triggerRemoveContractAdminAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is
block {
    
    // fetch params begin ---
    const adminAddress  : address               = unpackAddress(actionRecord, "adminAddress");
    const contractAddressList  : list(address)  = unpackListAddress(actionRecord, "contractAddressList");
    // fetch params end ---

    // loop over ccontract address list
    for contractAddress in list contractAddressList block {

        const adminContractTuple : (address * address) = (adminAddress, contractAddress);

        // verify contract admin address does not exist
        case s.contractAdminLedger[adminContractTuple] of [
                Some(_v) -> skip
            |   None     -> failwith(error_CONTRACT_ADMIN_ADDRESS_NOT_FOUND)
        ];
        
        // remove contract admin
        remove adminContractTuple from map s.contractAdminLedger;

    };

} with (s)



// helper function to trigger the updat config action during the sign
function triggerUpdateConfigAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is
block {
    
    // fetch params begin ---
    const configNewValue  : nat   = unpackNat(actionRecord, "configNewValue");
    const configAction  : string  = unpackString(actionRecord, "configAction");
    // fetch params end ---

    if configAction = "threshold" then {

        // Check that new threshold value should not be greater than signatory size
        if configNewValue > s.signatorySize then failwith(error_SIGNATORY_THRESHOLD_ERROR) else skip;

        s.config.threshold := configNewValue;

    } else if configAction = "actionExpiryInSeconds" then {

        // Check that new action expiry in seconds value should not be lower than 2 mins 
        if configNewValue < 120n then failwith(error_SIGNATORY_ACTION_EXPIRY_IN_SECONDS_TOO_LOW_ERROR) else skip;

        s.config.actionExpiryInSeconds := configNewValue;

    } else failwith(error_INVALID_CONFIG_ACTION);

} with (s)



// helper function to trigger the set super admin action during the signing
function triggerSetSuperAdminAction(const actionRecord : signatoryActionRecordType; var operations : list(operation)) : list(operation) is 
block {

    // fetch params begin ---
    const superAddress         : address = unpackAddress(actionRecord, "superAdminAddress");
    const contractAddressList  : list(address) = unpackListAddress(actionRecord, "contractAddressList");
    // fetch params end ---

    // loop over contract address list
    for contractAddress in list contractAddressList block {

        // create setSuperAdminOperation
        const setSuperAdminOperation : operation = setSuperAdminOperation(
            superAddress,
            contractAddress
        );
        
        operations := setSuperAdminOperation # operations;
    };

} with (operations)



// helper function to trigger the claim super admin action during the signing
function triggerClaimSuperAdminAction(const actionRecord : signatoryActionRecordType; var operations : list(operation)) : list(operation) is 
block {

    // fetch params begin ---
    const contractAddressList : list(address) = unpackListAddress(actionRecord, "contractAddressList");
    // fetch params end ---

    // loop over contract address list
    for contractAddress in list contractAddressList block {

        // create claimSuperAdminOperation
        const claimSuperAdminOperation : operation = claimSuperAdminOperation(
            contractAddress
        );
        
        operations := claimSuperAdminOperation # operations;

    }; 

} with (operations)



// helper function to trigger the add signatory action during the signing
function triggerAddSignatoryAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is 
block {

    // fetch params begin ---
    const signatoryAddressList : list(address) = unpackListAddress(actionRecord, "signatoryAddressList");
    // fetch params end ---

    // loop over signatory address list
    for signatoryAddress in list signatoryAddressList block {

        // verify signatory address does not exist
        case s.signatoryLedger[signatoryAddress] of [
                Some(_v) -> failwith(error_ADDRESS_IS_ALREADY_SIGNATORY)
            |   None     -> skip
        ];

        // add new signatory
        s.signatoryLedger[signatoryAddress] := unit;
        s.signatorySize                     := s.signatorySize + 1n;

    };

} with (s)



// helper function to trigger the remove signatory action during the sign
function triggerRemoveSignatoryAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is
block {

    // fetch params begin ---
    const signatoryAddressList : list(address) = unpackListAddress(actionRecord, "signatoryAddressList");
    // fetch params end ---

    // loop over signatory address list
    for signatoryAddress in list signatoryAddressList block {

        // verify signatory address exists
        case s.signatoryLedger[signatoryAddress] of [
                Some(_v) -> skip
            |   None     -> failwith(error_SIGNATORY_ADDRESS_NOT_FOUND)
        ];

        // Check if removing the signatory won't impact the threshold
        if (abs(s.signatorySize - 1n)) < s.config.threshold then failwith(error_SIGNATORY_THRESHOLD_ERROR)
        else skip;

        remove signatoryAddress from map s.signatoryLedger;
        s.signatorySize  := abs(s.signatorySize - 1n);

    };

} with (s)



// helper function to trigger the set token kyc action during the signing
function triggerSetTokenKycAction(const actionRecord : signatoryActionRecordType; var operations : list(operation)) : list(operation) is 
block {

    // fetch params begin ---
    const kycAddress          : address       = unpackAddress(actionRecord, "kycAddress");
    const contractAddressList : list(address) = unpackListAddress(actionRecord, "contractAddressList");
    // fetch params end ---

    for contractAddress in list contractAddressList block {

        // create setTokenKycOperation
        const setTokenKycOperation : operation = setTokenKycOperation(
            kycAddress,
            contractAddress
        );
        
        operations := setTokenKycOperation # operations;

    };

} with (operations)



// helper function to trigger the kill token action during the signing
function triggerKillTokenAction(const actionRecord : signatoryActionRecordType; var operations : list(operation)) : list(operation) is 
block {

    // fetch params begin ---
    const killTokenList  : list(address) = unpackListAddress(actionRecord, "killTokenList");
    // fetch params end ---

    // create killTokenOperation
    for contractAddress in list killTokenList{
        const killTokenOperation : operation = killTokenOperation(
            contractAddress
        );
        
        operations := killTokenOperation # operations;
    };

} with (operations)



// helper function to trigger the transfer action during the signing
function triggerTransferAction(const actionRecord : signatoryActionRecordType; var operations : list(operation)) : list(operation) is 
block {

    // fetch params begin ---
    const contractAddress       : address   = unpackAddress(actionRecord, "contractAddress");
    const receiverAddress       : address   = unpackAddress(actionRecord, "receiverAddress");
    const tokenContractAddress  : address   = unpackAddress(actionRecord, "tokenContractAddress");
    const tokenType             : string    = unpackString(actionRecord, "tokenType");
    const tokenAmount           : nat       = unpackNat(actionRecord, "tokenAmount");
    const tokenId               : nat       = unpackNat(actionRecord, "tokenId");
    // fetch params end ---
    
    // ---- initialise and set token type ----
    var _tokenTransferType : tokenType := Tez;

    if tokenType = "TEZ" then block {
        
        _tokenTransferType      := (Tez: tokenType); 

    } else if tokenType = "FA12" then block {
        
        _tokenTransferType      := (Fa12(tokenContractAddress) : tokenType);

    } else if tokenType = "FA2" then block {

        _tokenTransferType     := (Fa2(record [
            tokenContractAddress    = tokenContractAddress;
            tokenId                 = tokenId;
        ]) : tokenType); 

    } else skip;
    // --- --- ---

    const transferOperation : operation = createTransferOperation(
        contractAddress,
        receiverAddress,
        tokenAmount,
        _tokenTransferType
    );

    operations := transferOperation # operations;

} with (operations)



// helper function to trigger the flush action action during the sign
function triggerFlushActionAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is
block {

    // fetch params begin ---
    const flushedSignatoryActionIdList : list(nat) = unpackListNat(actionRecord, "actionIdList");
    // fetch params end ---

    for actionId in list flushedSignatoryActionIdList block {
        
        var flushedSignatoryActionRecord : signatoryActionRecordType := case s.signatoryActionLedger[actionId] of [      
                Some(_record) -> _record
            |   None          -> failwith(error_SIGNATORY_ACTION_NOT_FOUND)
        ];

        // check if council can sign the action
        validateAction(flushedSignatoryActionRecord);

        flushedSignatoryActionRecord.status := "FLUSHED";
        s.signatoryActionLedger[actionId] := flushedSignatoryActionRecord;

    };

} with s



// helper function to trigger the set lambda action during the sign
function triggerSetLambdaAction(const actionRecord : signatoryActionRecordType; var s : superAdminStorageType) : superAdminStorageType is
block {

    // fetch params begin ---
    const lambdaName       : string  = unpackString(actionRecord, "lambdaName");
    const lambdaBytes      : bytes    = case actionRecord.dataMap["lambdaBytes"] of [
            Some(_bytes) -> _bytes
        |   None -> failwith(error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND)
    ];
    // fetch params end ---

    s.lambdaLedger[lambdaName] := lambdaBytes;

} with s



// helper function to a signatory action during the signing
function executeSignatoryAction(var actionRecord : signatoryActionRecordType; const actionId : actionIdType; var operations : list(operation); var s : superAdminStorageType) : return is
block {

    // --------------------------------------
    // execute action based on action types
    // --------------------------------------

    const actionType : string = actionRecord.actionType;

    // ------------------------------------------------------------------------------
    // Signatory Actions for Contract Admin Begin
    // ------------------------------------------------------------------------------

    // setGeneralAdmin action type
    if actionType = "setGeneralAdmin" then s          := triggerSetGeneralAdminAction(actionRecord, s);

    // removeGeneralAdmin action type
    if actionType = "removeGeneralAdmin" then s       := triggerRemoveGeneralAdminAction(actionRecord, s);

    // setContractAdmin action type
    if actionType = "setContractAdmin" then s         := triggerSetContractAdminAction(actionRecord, s);

    // removeContractAdmin action type
    if actionType = "removeContractAdmin" then s      := triggerRemoveContractAdminAction(actionRecord, s);

    // updateConfig action type
    if actionType = "updateConfig" then s             := triggerUpdateConfigAction(actionRecord, s);

    // ------------------------------------------------------------------------------
    // Signatory Actions for Contract Admin End
    // ------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------
    // Signatory Actions for Super Admin Begin
    // ------------------------------------------------------------------------------

    // setSuperAdmin action type
    if actionType = "setSuperAdmin" then operations      := triggerSetSuperAdminAction(actionRecord, operations);

    // claimSuperAdmin action type
    if actionType = "claimSuperAdmin" then operations    := triggerClaimSuperAdminAction(actionRecord, operations);

    // ------------------------------------------------------------------------------
    // Signatory Actions for Super Admin End
    // ------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------
    // Signatory Actions for Signatory Begin
    // ------------------------------------------------------------------------------

    // addSignatory action type
    if actionType = "addSignatory" then s                := triggerAddSignatoryAction(actionRecord, s);

    // removeSignatory action type
    if actionType = "removeSignatory" then s             := triggerRemoveSignatoryAction(actionRecord, s);
    
    // ------------------------------------------------------------------------------
    // Signatory Actions for Signatory End
    // ------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------
    // Signatory Actions for Token Begin
    // ------------------------------------------------------------------------------

    // setTokenKyc action type
    if actionType = "setTokenKyc" then operations        := triggerSetTokenKycAction(actionRecord, operations);

    // killToken action type
    if actionType = "killToken" then operations          := triggerKillTokenAction(actionRecord, operations);

    // ------------------------------------------------------------------------------
    // Signatory Actions for Token End
    // ------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------
    // Tresaury Transfer Actions for Token Begin
    // ------------------------------------------------------------------------------

    // transfer action type
    if actionType = "transfer" then operations           := triggerTransferAction(actionRecord, operations);

    // ------------------------------------------------------------------------------
    // Tresaury Transfer Actions for Token End
    // ------------------------------------------------------------------------------
    

    // ------------------------------------------------------------------------------
    // Flush Action Begin
    // ------------------------------------------------------------------------------

    // flush action type
    if actionType = "flushAction" then s                := triggerFlushActionAction(actionRecord, s);

    // ------------------------------------------------------------------------------
    // Flush Action End
    // ------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------
    // Lambda Action Begin
    // ------------------------------------------------------------------------------

    // flush action type
    if actionType = "setLambda" then s                  := triggerSetLambdaAction(actionRecord, s);

    // ------------------------------------------------------------------------------
    // Lambda Action End
    // ------------------------------------------------------------------------------


    // ------------------------------------------------------------------------------
    // Signatory Signing of Actions 
    // ------------------------------------------------------------------------------

    // update signatory action record status
    actionRecord.status              := "EXECUTED";
    actionRecord.executed            := True;
    actionRecord.executedDateTime    := Some(Tezos.get_now());
    actionRecord.executedLevel       := Some(Tezos.get_level());
    
    // save signatory action record
    s.signatoryActionLedger[actionId] := actionRecord;

} with (operations, s)

// ------------------------------------------------------------------------------
// Sign Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to unpack and execute entrypoint logic stored as bytes in lambdaLedger
function unpackLambda(const lambdaBytes : bytes; const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(superAdminUnpackLambdaFunctionType)) of [
            Some(f) -> f(superAdminLambdaAction, s)
        |   None    -> failwith(error_UNABLE_TO_UNPACK_LAMBDA)
    ];

} with (res.0, res.1)

// ------------------------------------------------------------------------------
// Lambda Helper Functions End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Helper Functions End
//
// ------------------------------------------------------------------------------
