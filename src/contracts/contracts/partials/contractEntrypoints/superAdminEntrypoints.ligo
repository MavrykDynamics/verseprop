// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setGeneralAdmin entrypoint *)
function setGeneralAdmin(const newAdminAddress : list(address); var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetGeneralAdmin", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaSetGeneralAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response


(*  removeGeneralAdmin entrypoint *)
function removeGeneralAdmin(const adminAddress : list(address); var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveGeneralAdmin", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaRemoveGeneralAdmin(adminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response



(*  setContractAdmin entrypoint *)
function setContractAdmin(const setContractAdminParams : setContractAdminActionType; var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetContractAdmin", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaSetContractAdmin(setContractAdminParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response



(*  removeContractAdmin entrypoint *)
function removeContractAdmin(const removeContractAdminParams : setContractAdminActionType; var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveContractAdmin", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaRemoveContractAdmin(removeContractAdminParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response



(* updateConfig entrypoint *)
function updateConfig(const updateConfigParams : superAdminUpdateConfigParamsType; var s : superAdminStorageType) : return is 
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateConfig", s.lambdaLedger);

    // init delegation lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaUpdateConfig(updateConfigParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);

} with response

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Super Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const setSuperAdminParams : setSuperAdminActionType; var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSuperAdmin", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaSetSuperAdmin(setSuperAdminParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(const contractAddresses : list(address); var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaClaimSuperAdmin", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaClaimSuperAdmin(contractAddresses);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Super Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Signatory Entrypoints Begin
// ------------------------------------------------------------------------------

(*  addSignatory entrypoint *)
function addSignatory(const signatoryAddress : list(address); var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaAddSignatory", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaAddSignatory(signatoryAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response



(*  removeSignatory entrypoint *)
function removeSignatory(const signatoryAddress : list(address); var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveSignatory", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaRemoveSignatory(signatoryAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Signatory Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Token Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setTokenKyc entrypoint *)
function setTokenKyc(const setTokenKycParams : setTokenKycActionType; var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetTokenKyc", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaSetTokenKyc(setTokenKycParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response



(*  killToken entrypoint *)
function killToken(const killTokenParams : list(address); var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaKillToken", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaKillToken(killTokenParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Token Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Treasury Transfer Entrypoints Begin
// ------------------------------------------------------------------------------

(*  transfer entrypoint *)
function transfer(const superAdminTransferParams : superAdminTransferActionType; var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaTransfer", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaTransfer(superAdminTransferParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Treasury Transfer Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeping Entrypoints Begin
// ------------------------------------------------------------------------------

(*  updateMetadata entrypoint: update the metadata at a given key *)
function updateMetadata(const updateMetadataParams : updateMetadataType; var s : superAdminStorageType) : return is
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMetadata", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaUpdateMetadata(updateMetadataParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  

} with response



(*  mistakenTransfer entrypoint *)
function mistakenTransfer(const destinationParams : transferActionType; var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaMistakenTransfer", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaMistakenTransfer(destinationParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Signing Entrypoints Begin
// ------------------------------------------------------------------------------

(*  flushAction entrypoint *)
function flushAction(const actionIdList : list(nat); var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaFlushAction", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaFlushAction(actionIdList);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response



(*  signAction entrypoint *)
function signAction(const actionIdList : list(nat); var s : superAdminStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSignAction", s.lambdaLedger);

    // init superAdmin lambda action
    const superAdminLambdaAction : superAdminLambdaActionType = LambdaSignAction(actionIdList);

    // init response
    const response : return = unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Signing Entrypoints Begin
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Entrypoints Begin
// ------------------------------------------------------------------------------

(* setLambda entrypoint *)
function setLambda(const setLambdaParams : setLambdaType; var s : superAdminStorageType) : return is
block{

    var response : return := (list[], s);
    
    if s.actionCounter = 0n then {
        // on first initialisation of contract
        
        // check that sender is signatory
        verifySenderIsSignatory(s);     

        const lambdaName    = setLambdaParams.name;
        const lambdaBytes   = setLambdaParams.func_bytes;
        
        s.lambdaLedger[lambdaName] := lambdaBytes;
        response.1                 := s;

    } else {

        // get lambda bytes
        const lambdaBytes : bytes = getLambdaBytes("lambdaSetLambda", s.lambdaLedger);

        // init superAdmin lambda action
        const superAdminLambdaAction : superAdminLambdaActionType = LambdaSetLambda(setLambdaParams);

        // init response
        response := unpackLambda(lambdaBytes, superAdminLambdaAction, s);  
        
    };

} with response

// ------------------------------------------------------------------------------
// Lambda Entrypoints End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Entrypoints End
//
// ------------------------------------------------------------------------------