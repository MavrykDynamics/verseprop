// ------------------------------------------------------------------------------
//
// Views Begin
//
// ------------------------------------------------------------------------------

(* View: verify user is general admin *)
[@view] function verifyUserIsGeneralAdmin(const user : address; const s : superAdminStorageType) : bool is
block {

    const userIsGeneralAdmin : bool = case s.generalAdminLedger[user] of [
            Some(_v) -> True
        |   None     -> False
    ];

} with userIsGeneralAdmin



(* View: verify user is contract admin *)
[@view] function verifyUserIsContractAdmin(const userTokenTuple : (address * address); const s : superAdminStorageType) : bool is
block {

    const userIsContractAdmin : bool = case s.contractAdminLedger[userTokenTuple] of [
            Some(_) -> True
        |   None    -> False
    ];

} with userIsContractAdmin
    


(* View: get a lambda *)
[@view] function getLambdaOpt(const lambdaName: string; const s : superAdminStorageType) : option(bytes) is
    Big_map.find_opt(lambdaName, s.lambdaLedger)

// ------------------------------------------------------------------------------
//
// Views End
//
// ------------------------------------------------------------------------------