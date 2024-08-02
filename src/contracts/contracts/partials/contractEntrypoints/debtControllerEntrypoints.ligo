// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Super Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetSuperAdmin", s.lambdaLedger);

    // init debtController lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaSetSuperAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  
    
} with response



// (*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaClaimSuperAdmin", s.lambdaLedger);

    // init debtController lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaClaimSuperAdmin(unit);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Super Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  addManager entrypoint *)
function addManager(const newManagerAddress : address; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaAddManager", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaAddManager(newManagerAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  
    
} with response



(*  removeManager entrypoint *)
function removeManager(const managerAddress : address; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveManager", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaRemoveManager(managerAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  
    
} with response



(*  addAdmin entrypoint *)
function addAdmin(const newAdminAddress : address; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaAddAdmin", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaAddAdmin(newAdminAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  
    
} with response


(*  removeAdmin entrypoint *)
function removeAdmin(const adminToRemove : address; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaRemoveAdmin", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaRemoveAdmin(adminToRemove);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  
    
} with response



(*  setKycAddress entrypoint *)
function setKycAddress(const newKycAddress : address; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetKycAddress", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaSetKycAddress(newKycAddress);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  
    
} with response



(*  updateMetadata entrypoint *)
function updateMetadata(const updateMetadataParams : updateMetadataType; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateMetadata", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaUpdateMetadata(updateMetadataParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  
    
} with response

// ------------------------------------------------------------------------------
// Admin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Admin Debt Controller Entrypoints Begin
// ------------------------------------------------------------------------------

(*  addDebt entrypoint *)
function addDebt(const addDebtParams : addDebtActionType; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaAddDebt", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaAddDebt(addDebtParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response



(*  updateDebt entrypoint *)
function updateDebt(const updateDebtParams : updateDebtActionType; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaUpdateDebt", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaUpdateDebt(updateDebtParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response



(*  setInvestment entrypoint *)
function setInvestment(const setInvestmentParams : setInvestmentActionType; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetInvestment", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaSetInvestment(setInvestmentParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response



(*  setFeeWallet entrypoint *)
function setFeeWallet(const feeWallet : address; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaSetFeeWallet", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaSetFeeWallet(feeWallet);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Admin Debt Controller Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Debt Controller Entrypoints Begin
// ------------------------------------------------------------------------------

(*  createDebt entrypoint *)
function createDebt(const createDebtParams : createDebtActionType; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaCreateDebt", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaCreateDebt(createDebtParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response



(*  disburseLoan entrypoint *)
function disburseLoan(const debtId : nat; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaDisburseLoan", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaDisburseLoan(debtId);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response



(*  returnDeposit entrypoint *)
function returnDeposit(const debtId : nat; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaReturnDeposit", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaReturnDeposit(debtId);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response



(*  addDeposit entrypoint *)
function addDeposit(const addDepositParams : addDepositActionType; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaAddDeposit", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaAddDeposit(addDepositParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response



(*  withdrawDeposit entrypoint *)
function withdrawDeposit(const withdrawDepositParams : withdrawDepositActionType; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaWithdrawDeposit", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaWithdrawDeposit(withdrawDepositParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response



(*  payOffDebt entrypoint *)
function payOffDebt(const payOffDebtParams : payOffDebtActionType; var s : debtControllerStorageType) : return is
block {

    // get lambda bytes
    const lambdaBytes : bytes = getLambdaBytes("lambdaPayOffDebt", s.lambdaLedger);

    // init debt controller lambda action
    const debtControllerLambdaAction : debtControllerLambdaActionType = LambdaPayOffDebt(payOffDebtParams);

    // init response
    const response : return = unpackLambda(lambdaBytes, debtControllerLambdaAction, s);  

} with response

// ------------------------------------------------------------------------------
// Debt Controller Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Entrypoints Begin
// ------------------------------------------------------------------------------

(* setLambda entrypoint *)
function setLambda(const setLambdaParams : setLambdaType; var s : debtControllerStorageType) : return is
block{
    
    onlyAdmin(s.admins);
    
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