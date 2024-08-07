// ------------------------------------------------------------------------------
//
// SuperAdmin Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Set Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setGeneralAdmin lambda *)
function lambdaSetGeneralAdmin(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaSetGeneralAdmin(generalAdminAddressList) -> {

                const dataMap : dataMapType = map [
                    ("generalAdminAddressList" : string) -> Bytes.pack(generalAdminAddressList);
                ];

                // loop over general admin address list
                for generalAdminAddress in list generalAdminAddressList block { 

                    // verify address is not already general admin
                    case s.generalAdminLedger[generalAdminAddress] of [
                            Some(_v) -> failwith(error_ADDRESS_IS_ALREADY_GENERAL_ADMIN)
                        |   None     -> skip
                    ];

                };

                // create signatory action
                s := createSignatoryAction(
                    "setGeneralAdmin",
                    dataMap,
                    s
                );

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeGeneralAdmin lambda *)
function lambdaRemoveGeneralAdmin(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaRemoveGeneralAdmin(generalAdminAddressList) -> {

                const dataMap : dataMapType = map [
                    ("generalAdminAddressList" : string) -> Bytes.pack(generalAdminAddressList);
                ];

                // loop over general admin address list
                for generalAdminAddress in list generalAdminAddressList block { 

                    // verify general admin address exists
                    case s.generalAdminLedger[generalAdminAddress] of [
                            Some(_v) -> skip
                        |   None     -> failwith(error_ADDRESS_NOT_GENERAL_ADMIN)
                    ];

                };

                // create signatory action
                s := createSignatoryAction(
                    "removeGeneralAdmin",
                    dataMap,
                    s
                );

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  setContractAdmin lambda *)
function lambdaSetContractAdmin(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaSetContractAdmin(setContractAdminParams) -> {

                const adminAddress : address = setContractAdminParams.adminAddress;
                const contractAddressList : list(address) = setContractAdminParams.contractAddressList;

                const dataMap : dataMapType = map [
                    ("adminAddress" : string)        -> Bytes.pack(adminAddress);
                    ("contractAddressList" : string) -> Bytes.pack(contractAddressList);
                ];

                // loop over contract address list
                for contractAddress in list contractAddressList block {

                    const adminContractTuple : (address * address) = (adminAddress, contractAddress);

                    // verify contract admin address does not exist
                    case s.contractAdminLedger[adminContractTuple] of [
                            Some(_v) -> failwith(error_ADDRESS_IS_ALREADY_CONTRACT_ADMIN)
                        |   None     -> skip
                    ];

                };

                // create signatory action
                s := createSignatoryAction(
                    "setContractAdmin",
                    dataMap,
                    s
                );

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeContractAdmin lambda *)
function lambdaRemoveContractAdmin(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaRemoveContractAdmin(removeContractAdminParams) -> {
                
                const adminAddress : address              = removeContractAdminParams.adminAddress;
                const contractAddressList : list(address) = removeContractAdminParams.contractAddressList;

                const dataMap : dataMapType = map [
                    ("adminAddress" : string)    -> Bytes.pack(adminAddress);
                    ("contractAddressList" : string) -> Bytes.pack(contractAddressList);
                ];

                // loop over contract address list
                for contractAddress in list contractAddressList block {

                    const adminContractTuple : (address * address) = (adminAddress, contractAddress);

                    // verify contract admin address exists
                    case s.contractAdminLedger[adminContractTuple] of [
                            Some(_v) -> skip
                        |   None     -> failwith(error_CONTRACT_ADMIN_ADDRESS_NOT_FOUND)
                    ];
                    
                };

                // create signatory action
                s := createSignatoryAction(
                    "removeContractAdmin",
                    dataMap,
                    s
                );
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* updateConfig lambda *)
function lambdaUpdateConfig(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is 
block {

    verifySenderIsSignatory(s); // check that sender is signatory

    case superAdminLambdaAction of [
        |   LambdaUpdateConfig(updateConfigParams) -> {

                const configNewValue : nat  = updateConfigParams.configNewValue;
                const configAction : string = updateConfigParams.configAction;

                // Check that new threshold value should not be greater than signatory size
                if configAction = "threshold" and configNewValue > s.signatorySize then failwith(error_SIGNATORY_THRESHOLD_ERROR) else skip;

                // Check that new action expiry in seconds value should not be lower than 2 mins 
                if configAction = "actionExpiryInSeconds" and configNewValue < 120n then failwith(error_SIGNATORY_ACTION_EXPIRY_IN_SECONDS_TOO_LOW_ERROR) else skip;

                const dataMap : dataMapType = map [
                    ("configNewValue" : string)    -> Bytes.pack(configNewValue);
                    ("configAction" : string)      -> Bytes.pack(configAction);
                ];

                // create signatory action
                s := createSignatoryAction(
                    "updateConfig",
                    dataMap,
                    s
                );

            }
        |   _ -> skip
    ];
  
} with (noOperations, s)

// ------------------------------------------------------------------------------
// Set Admin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// SuperAdmin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin lambda *)
function lambdaSetSuperAdmin(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaSetSuperAdmin(setSuperAdminParams) -> {
                
                const dataMap : dataMapType = map [
                    ("superAdminAddress" : string)      -> Bytes.pack(setSuperAdminParams.superAdminAddress);
                    ("contractAddressList" : string)    -> Bytes.pack(setSuperAdminParams.contractAddressList);
                ];

                // create signatory action
                s := createSignatoryAction(
                    "setSuperAdmin",
                    dataMap,
                    s
                );
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  claimSuperAdmin lambda *)
function lambdaClaimSuperAdmin(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaClaimSuperAdmin(contractAddressList) -> {
                
                const dataMap : dataMapType = map [
                    ("contractAddressList" : string)    -> Bytes.pack(contractAddressList);
                ];

                // create signatory action
                s := createSignatoryAction(
                    "claimSuperAdmin",
                    dataMap,
                    s
                );
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// SuperAdmin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Signatory Lambdas Begin
// ------------------------------------------------------------------------------

(*  addSignatory lambda *)
function lambdaAddSignatory(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaAddSignatory(signatoryAddressList) -> {
                
                const dataMap : dataMapType = map [
                    ("signatoryAddressList" : string)  -> Bytes.pack(signatoryAddressList);
                ];

                // verify signatory address does not exist
                for signatoryAddress in list signatoryAddressList block {
                    case s.signatoryLedger[signatoryAddress] of [
                            Some(_v) -> failwith(error_ADDRESS_IS_ALREADY_SIGNATORY)
                        |   None     -> skip
                    ];
                };

                // create signatory action
                s := createSignatoryAction(
                    "addSignatory",
                    dataMap,
                    s
                );
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  removeSignatory lambda *)
function lambdaRemoveSignatory(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaRemoveSignatory(signatoryAddressList) -> {
                
                const dataMap : dataMapType = map [
                    ("signatoryAddressList" : string)  -> Bytes.pack(signatoryAddressList);
                ];

                // verify signatory address exists
                for signatoryAddress in list signatoryAddressList block {
                    case s.signatoryLedger[signatoryAddress] of [
                            Some(_v) -> skip
                        |   None     -> failwith(error_SIGNATORY_ADDRESS_NOT_FOUND)
                    ];
                };

                // create signatory action
                s := createSignatoryAction(
                    "removeSignatory",
                    dataMap,
                    s
                );
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// SuperAdmin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeeping Lambdas Begin
// ------------------------------------------------------------------------------

(*  updateMetadata lambda - update the metadata at a given key *)
function lambdaUpdateMetadata(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {
    
    // verify that sender is contract admin
    verifySenderIsContractAdmin(s);

    case superAdminLambdaAction of [
        |   LambdaUpdateMetadata(updateMetadataParams) -> {
                
                const metadataKey   : string = updateMetadataParams.metadataKey;
                const metadataHash  : bytes  = updateMetadataParams.metadataHash;
                
                s.metadata[metadataKey] := metadataHash;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  mistakenTransfer lambda *)
function lambdaMistakenTransfer(const superAdminLambdaAction : superAdminLambdaActionType; var s: superAdminStorageType) : return is
block {

    var operations : list(operation) := nil;

    case superAdminLambdaAction of [
        |   LambdaMistakenTransfer(destinationParams) -> {

                // verify that sender is contract admin
                verifySenderIsContractAdmin(s);

                // Create transfer operations (transferOperationFold in transferHelpers)
                operations := List.fold_right(transferOperationFold, destinationParams, operations)
                
            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
// Housekeeping Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Token Lambdas Begin
// ------------------------------------------------------------------------------

(*  setTokenKyc lambda *)
function lambdaSetTokenKyc(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaSetTokenKyc(setTokenKycParams) -> {

                const kycAddress            : address       = setTokenKycParams.kycAddress;
                const contractAddressList   : list(address) = setTokenKycParams.contractAddressList;
                
                const dataMap : dataMapType = map [
                    ("kycAddress" : string)       -> Bytes.pack(kycAddress);
                    ("contractAddressList" : string)  -> Bytes.pack(contractAddressList);
                ];

                // create signatory action
                s := createSignatoryAction(
                    "setTokenKyc",
                    dataMap,
                    s
                );
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  killToken lambda *)
function lambdaKillToken(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaKillToken(killTokenList) -> {

                const dataMap : dataMapType = map [
                    ("killTokenList" : string) -> Bytes.pack(killTokenList);
                ];

                // create signatory action
                s := createSignatoryAction(
                    "killToken",
                    dataMap,
                    s
                );
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Token Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Treasury Transfer Lambdas Begin
// ------------------------------------------------------------------------------

(*  transfer lambda *)
function lambdaTransfer(const superAdminLambdaAction : superAdminLambdaActionType; var s: superAdminStorageType) : return is
block {

    var operations : list(operation) := nil;

    verifySenderIsSignatory(s); // check that sender is signatory

    case superAdminLambdaAction of [
        |   LambdaTransfer(superAdminTransferParams) -> {

                // Verify that token type is correct
                verifyCorrectTokenType(superAdminTransferParams.tokenType);

                const dataMap : dataMapType = map [
                    ("contractAddress"       : string) -> Bytes.pack(superAdminTransferParams.contractAddress);
                    ("receiverAddress"       : string) -> Bytes.pack(superAdminTransferParams.receiverAddress);
                    ("tokenContractAddress"  : string) -> Bytes.pack(superAdminTransferParams.tokenContractAddress);
                    ("tokenType"             : string) -> Bytes.pack(superAdminTransferParams.tokenType);
                    ("tokenAmount"           : string) -> Bytes.pack(superAdminTransferParams.tokenAmount);
                    ("tokenId"               : string) -> Bytes.pack(superAdminTransferParams.tokenId);
                ];

                // create signatory action
                s := createSignatoryAction(
                    "transfer",
                    dataMap,
                    s
                );
                
            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
// Treasury Transfer Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Signing Lambdas Begin
// ------------------------------------------------------------------------------

(*  flushAction lambda *)
function lambdaFlushAction(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaFlushAction(actionIdList) -> {

                // validate each action id
                for actionId in list actionIdList block {

                    // Verify that council action exists
                    verifySignatoryActionExists(actionId, s);

                    // check if action is not flushed / executed / expired
                    validateActionById(actionId, s);

                };

                const dataMap : dataMapType = map [
                    ("actionIdList" : string) -> Bytes.pack(actionIdList);
                ];

                // create council action
                s := createSignatoryAction(
                    "flushAction",
                    dataMap,
                    s
                );

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  signAction lambda *)
function lambdaSignAction(const superAdminLambdaAction : superAdminLambdaActionType; var s : superAdminStorageType) : return is
block {

    var operations : list(operation) := nil;

    verifySenderIsSignatory(s); // check that sender is signatory
    
    case superAdminLambdaAction of [
        |   LambdaSignAction(actionIdList) -> {

                for actionId in list actionIdList block {

                    // Verify that signatory action exists
                    verifySignatoryActionExists(actionId, s);

                    // check if action is not flushed / executed / expired
                    validateActionById(actionId, s);

                    var signatoryActionRecord : signatoryActionRecordType := getSignatoryActionRecord(actionId, s);

                    // check if signatory has already signed for this action
                    if Big_map.mem((Mavryk.get_sender(), actionId), s.signatureLedger) then failwith(error_SIGNATORY_ACTION_ALREADY_SIGNED_BY_SENDER) else skip;

                    // update signers and signersCount for signatory action record
                    var signersCount : nat               := signatoryActionRecord.signersCount + 1n;
                    signatoryActionRecord.signersCount   := signersCount;
                    s.signatureLedger                    := Big_map.add((Mavryk.get_sender(), actionId), unit, s.signatureLedger);
                    s.signatoryActionLedger[actionId]    := signatoryActionRecord;

                    // check if threshold has been reached
                    if signersCount >= s.config.threshold and not signatoryActionRecord.executed then block {
                        
                        const executeSignatoryActionReturn : return = executeSignatoryAction(signatoryActionRecord, actionId, operations, s);
                        
                        s          := executeSignatoryActionReturn.1;
                        operations := executeSignatoryActionReturn.0;

                    } else skip;
                    
                };

            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
// Lambdas Begin
// ------------------------------------------------------------------------------

(*  setLambda lambda *)
function lambdaSetLambda(const superAdminLambdaAction : superAdminLambdaActionType; var s: superAdminStorageType) : return is
block {

    case superAdminLambdaAction of [
        |   LambdaSetLambda(setLambdaParams) -> {

                verifySenderIsSignatory(s); // check that sender is signatory

                const dataMap : dataMapType = map [
                    ("lambdaName"       : string) -> Bytes.pack(setLambdaParams.name);
                    ("lambdaBytes"      : string) -> setLambdaParams.func_bytes;
                ];

                // create signatory action
                s := createSignatoryAction(
                    "setLambda",
                    dataMap,
                    s
                );
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Lambdas End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// SuperAdmin Lambdas End
//
// ------------------------------------------------------------------------------