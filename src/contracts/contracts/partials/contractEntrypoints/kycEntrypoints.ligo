// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSuperAdmin", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaSetSuperAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaClaimSuperAdmin", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaClaimSuperAdmin(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Kyc Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setCountryTransferRule entrypoint *)
function setCountryTransferRule(const setCountryTransferRuleParams : setCountryTransferRuleActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetCountryTransferRule", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaSetCountryTransferRule(setCountryTransferRuleParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response



(*  setKycRegistrar entrypoint *)
function setKycRegistrar(const setKycRegistrarParams : setKycRegistrarActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetKycRegistrar", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaSetKycRegistrar(setKycRegistrarParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response



(*  pauseKycRegistrar entrypoint *)
function pauseKycRegistrar(const pauseKycRegistrarParams : pauseKycRegistrarActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPauseKycRegistrar", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaPauseKycRegistrar(pauseKycRegistrarParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response



(*  setValidInput entrypoint *)
function setValidInput(const setValidInputParams : setValidInputActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetValidInput", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaSetValidInput(setValidInputParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response



(*  setWhitelist entrypoint *)
function setWhitelist(const setWhitelistParams : setWhitelistActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetWhitelist", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaSetWhitelist(setWhitelistParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response



(*  setBlacklist entrypoint *)
function setBlacklist(const setBlacklistParams : setBlacklistActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetBlacklist", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaSetBlacklist(setBlacklistParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Kyc Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------

(*  updateMetadata entrypoint: update the metadata at a given key *)
function updateMetadata(const updateMetadataParams : updateMetadataType; var s : kycStorageType) : return is
block {
    
    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMetadata", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaUpdateMetadata(updateMetadataParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  

} with response



(*  mistakenTransfer entrypoint *)
function mistakenTransfer(const destinationParams : transferActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaMistakenTransfer", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaMistakenTransfer(destinationParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints Begin
// ------------------------------------------------------------------------------

(*  pauseAll entrypoint *)
function pauseAll(var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPauseAll", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaPauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  
    
} with response



(*  unpauseAll entrypoint *)
function unpauseAll(var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUnpauseAll", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaUnpauseAll(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  

} with response



(*  togglePauseEntrypoint entrypoint  *)
function togglePauseEntrypoint(const targetEntrypoint : kycTogglePauseEntrypointType; const s : kycStorageType) : return is
block{

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaTogglePauseEntrypoint", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaTogglePauseEntrypoint(targetEntrypoint);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);

} with response

// ------------------------------------------------------------------------------
// Pause / Break Glass Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// KYC Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setMember entrypoint *)
function setMember(const setMemberParams : setMemberActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetMember", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaSetMember(setMemberParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  

} with response



(*  setRegistrarAdmin entrypoint *)
function setRegistrarAdmin(const setRegistrarAdminParams : setRegistrarAdminActionType; var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetRegistrarAdmin", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaSetRegistrarAdmin(setRegistrarAdminParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  

} with response



(*  freezeMember entrypoint *)
function freezeMember(const memberAddress : list(address); var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaFreezeMember", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaFreezeMember(memberAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  

} with response



(*  unfreezeMember entrypoint *)
function unfreezeMember(const memberAddress : list(address); var s : kycStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUnfreezeMember", s.lambdaLedger);

    // init kyc lambda action
    const kycLambdaAction : kycLambdaActionType = LambdaUnfreezeMember(memberAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, kycLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// kyc Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Entrypoints Begin
// ------------------------------------------------------------------------------

(* setLambda entrypoint *)
function setLambda(const setLambdaParams : setLambdaType; var s : kycStorageType) : return is
block{
    
    verifySenderIsSuperAdmin(s); 
    
    // assign params to constants for better code readability
    const lambdaName    = setLambdaParams.name;
    const lambdaBytes   = setLambdaParams.func_bytes;
    s.lambdaLedger[lambdaName] := lambdaBytes;

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Lambda Entrypoints End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Entrypoints End
//
// ------------------------------------------------------------------------------