// ------------------------------------------------------------------------------
//
// Views Begin
//
// ------------------------------------------------------------------------------

(* View: get super admin variable *)
[@view] function getSuperAdmin(const _ : unit; const s : kycStorageType) : address is
    s.superAdmin


(* View: get new super admin variable *)
[@view] function getNewSuperAdmin(const _ : unit; const s : kycStorageType) : option(address) is
    s.newSuperAdmin


(* view_is_transfer_valid *)
[@view] function view_is_transfer_valid(const validation_transfer : validationTransferType; var s : kycStorageType) : bool is
block {

    var is_transfer_valid : bool := False;

    // notes: best to set up any 3rd-party contracts (e.g. marketplace) as a KYC-ed member too

    const from_is_whitelisted : bool = case s.whitelistLedger[validation_transfer.from_] of [
            Some(_) -> True
        |   None    -> False
    ];

    const to_is_whitelisted : bool = case s.whitelistLedger[validation_transfer.to_] of [
            Some(_) -> True
        |   None    -> False
    ];
    
    // -----------------------------------
    // from_ (sender) validation checks
    // -----------------------------------

    const from_is_blacklisted : bool = case s.blacklistLedger[validation_transfer.from_] of [
            Some(_) -> True
        |   None    -> False
    ];

    const from_is_frozen : bool = case s.memberLedger[validation_transfer.from_] of [
            Some (_memberRecord) -> _memberRecord.frozen
        |   None      -> False
    ];

    var from_member_kyc_does_not_exist : bool := True;
    const from_member_record : memberRecordType = case s.memberLedger[validation_transfer.from_] of [
            Some (_memberRecord) -> { from_member_kyc_does_not_exist := False } with _memberRecord
        |   None -> failwith(error_FROM_KYC_MEMBER_DOES_NOT_EXIST)
    ];

    var from_country_exists : bool := False;
    const from_country_rules : countryTransferRuleRecordType = case s.countryTransferRuleLedger[from_member_record.country] of [
            Some(_countryRules) -> { from_country_exists := True } with _countryRules
        |   None                -> failwith(error_COUNTRY_TRANSFER_RULE_RECORD_NOT_FOUND)
    ];

    const country_rule_sending_frozen : bool = from_country_rules.sendingFrozen;

    // -----------------------------------
    // to_ (receiver) validation checks
    // -----------------------------------

    const to_is_blacklisted : bool = case s.blacklistLedger[validation_transfer.to_] of [
            Some(_) -> True
        |   None    -> False
    ];

    const to_is_frozen : bool = case s.memberLedger[validation_transfer.to_] of [
            Some (_memberRecord) -> _memberRecord.frozen
        |   None      -> False
    ];

    var to_member_kyc_does_not_exist : bool := True;
    const to_member_record : memberRecordType = case s.memberLedger[validation_transfer.to_] of [
            Some (_memberRecord) -> { to_member_kyc_does_not_exist := False } with _memberRecord
        |   None -> failwith(error_TO_KYC_MEMBER_DOES_NOT_EXIST)
    ];

    var to_country_exists : bool := False;
    const to_country_rules : countryTransferRuleRecordType = case s.countryTransferRuleLedger[to_member_record.country] of [
            Some(_countryRules) -> { to_country_exists := True } with _countryRules
        |   None                -> failwith(error_COUNTRY_TRANSFER_RULE_RECORD_NOT_FOUND)
    ];

    const country_rule_receiving_frozen : bool = to_country_rules.receivingFrozen;

    // check if to_country is blacklisted by from_country
    const to_country_blacklisted_by_from_country : bool = Set.mem(to_member_record.country, from_country_rules.blacklistCountries);


    if to_is_whitelisted then is_transfer_valid := True  // receiver is whitelisted (e.g. 3rd-party custodial marketplace)
    else if from_is_whitelisted then {
        // sender is whitelisted (e.g. 3rd-party custodial marketplace)
        // check that to_ can receive
        is_transfer_valid := 
            if 
                to_is_frozen = True 
                or country_rule_receiving_frozen = True 
                or to_is_blacklisted = True 
                or to_member_kyc_does_not_exist = True 
            then False
            else True;
    }
    else {

        // check if transfer is valid
        //   - sender or receiver cannot be frozen
        //   - country rules sending or country rules receiving is frozen
        //   - receiver country blacklisted by sender country
        //   - sender or receiver is blacklisted by kyc 
        //   - sender or receiver must have kyc done (exists in member ledger)
        is_transfer_valid := 
            if 
                from_is_frozen = True or to_is_frozen = True 
                or country_rule_sending_frozen = True or country_rule_receiving_frozen = True 
                or to_country_blacklisted_by_from_country = True
                or from_is_blacklisted = True or to_is_blacklisted = True 
                or from_member_kyc_does_not_exist = True or to_member_kyc_does_not_exist = True 
            then False
            else True;

    };

} with is_transfer_valid



(* View: get a lambda *)
[@view] function getLambdaOpt(const lambdaName: string; const s : kycStorageType) : option(bytes) is
    Big_map.find_opt(lambdaName, s.lambdaLedger)

// ------------------------------------------------------------------------------
//
// Views End
//
// ------------------------------------------------------------------------------