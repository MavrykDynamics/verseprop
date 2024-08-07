// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------

function verifySenderIsSuperAdmin(const s : kycStorageType) : unit is 
block {

    const sender : address = Mavryk.get_sender();
    if sender = s.superAdmin then skip else failwith(error_ONLY_SUPER_ADMINISTRATOR_ALLOWED);

} with unit



function verifySenderIsAdmin(const s : kycStorageType) : unit is 
block {

    const sender : address = Mavryk.get_sender();

    // check if contract admin
    const verifyUserIsContractAdminView : option (bool) = Mavryk.call_view("verifyUserIsContractAdmin", (sender, Mavryk.get_self_address()), s.superAdmin);
    const userIsContractAdmin : bool = case verifyUserIsContractAdminView of [
            Some (_bool) -> _bool
        |   None         -> failwith("error_VIEW_VERIFY_USER_IS_CONTRACT_ADMIN_NOT_FOUND")
    ];

    // pass if user is contract admin
    if userIsContractAdmin then skip else failwith(error_NOT_ADMIN);

} with unit



function verifySenderIsKycRegistrar(const s : kycStorageType) : unit is 
block {

    const sender : address = Mavryk.get_sender();

    // check if sender is kyc registrar
    case s.kycRegistrarLedger[sender] of [
            Some(_) -> skip
        |   None    -> failwith(error_ONLY_KYC_REGISTRAR_ALLOWED)
    ];

} with unit



function verifySenderIsAdminOrKycRegistrar(const s : kycStorageType) : unit is 
block {

    const sender : address = Mavryk.get_sender();

    const senderIsKycRegistrar : bool = case s.kycRegistrarLedger[sender] of [
            Some(_exist) -> True
        |   None         -> False
    ];

    // check if sender is contract admin
    const verifyUserIsContractAdminView : option (bool) = Mavryk.call_view("verifyUserIsContractAdmin", (sender, Mavryk.get_self_address()), s.superAdmin);
    const userIsContractAdmin : bool = case verifyUserIsContractAdminView of [
            Some (_bool) -> True
        |   None         -> False
    ];

    if senderIsKycRegistrar or userIsContractAdmin then skip else failwith(error_ONLY_ADMIN_OR_KYC_REGISTRAR_ALLOWED);

} with unit

// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Pause / BreakGlass Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to pause all entrypoints
function pauseAllKycEntrypoints(var s : kycStorageType) : kycStorageType is 
block {

    // set all pause configs to True
    if s.breakGlassConfig.setMemberIsPaused then skip
    else s.breakGlassConfig.setMemberIsPaused := True;

    if s.breakGlassConfig.freezeMemberIsPaused then skip
    else s.breakGlassConfig.freezeMemberIsPaused := True;

    if s.breakGlassConfig.unfreezeMemberIsPaused then skip
    else s.breakGlassConfig.unfreezeMemberIsPaused := True;

} with s



// helper function to unpause all entrypoints
function unpauseAllKycEntrypoints(var s : kycStorageType) : kycStorageType is 
block {

    // set all pause configs to False
    if s.breakGlassConfig.setMemberIsPaused then s.breakGlassConfig.setMemberIsPaused := False
    else skip;

    if s.breakGlassConfig.freezeMemberIsPaused then s.breakGlassConfig.freezeMemberIsPaused := False
    else skip;

    if s.breakGlassConfig.unfreezeMemberIsPaused then s.breakGlassConfig.unfreezeMemberIsPaused := False
    else skip;

} with s

// ------------------------------------------------------------------------------
// Pause / BreakGlass Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// General Helper Functions Begin
// ------------------------------------------------------------------------------

function getOrCreateValidInputSet(const validInputField : string; const s : kycStorageType) : set(string) is 
block {

    const validInputSet : set(string) = case s.validInputLedger[validInputField] of [
            Some(_set) -> _set
        |   None       -> set[]
    ];

} with validInputSet



function getValidInputSet(const validInputField : string; const s : kycStorageType) : set(string) is 
block {

    const validInputSet : set(string) = case s.validInputLedger[validInputField] of [
            Some(_set) -> _set
        |   None       -> failwith(error_VALID_INPUT_SET_NOT_FOUND)
    ];

} with validInputSet



function validateInput(const validInputField : string; const providedInput : string; const s : kycStorageType) : unit is 
block {

    const validInputSet : set(string) = getValidInputSet(validInputField, s);
    const providedInputIsValid : bool = validInputSet contains providedInput;
    if providedInputIsValid then skip else failwith(error_INVALID_INPUT);

} with unit

// ------------------------------------------------------------------------------
// Contract Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Lambda Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to unpack and execute entrypoint logic stored as bytes in lambdaLedger
function unpackLambda(const lambdaBytes : bytes; const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(kycUnpackLambdaFunctionType)) of [
            Some(f) -> f(kycLambdaAction, s)
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