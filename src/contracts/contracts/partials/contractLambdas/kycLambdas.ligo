// ------------------------------------------------------------------------------
//
// KYC Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin lambda *)
function lambdaSetSuperAdmin(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {

    verifySenderIsSuperAdmin(s); 
    
    case kycLambdaAction of [
        |   LambdaSetSuperAdmin(newAdminAddress) -> {
                s.newSuperAdmin := Some(newAdminAddress);
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  claimSuperAdmin lambda *)
function lambdaClaimSuperAdmin(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {
    
    case kycLambdaAction of [
        |   LambdaClaimSuperAdmin(_params) -> {
                
                // get sender and new super admin address 
                const sender : address = Mavryk.get_sender();
                const newSuperAdmin : address = case s.newSuperAdmin of [
                        Some(_address) -> _address
                    |   None           -> failwith(error_NO_NEW_SUPER_ADMIN_FOUND)
                ];

                // check if sender is not new super admin 
                if sender =/= newSuperAdmin then failwith(error_SENDER_IS_NOT_NEW_SUPER_ADMIN) else skip;
                s.superAdmin     := newSuperAdmin;
                s.newSuperAdmin  := None;

            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Admin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Housekeeping Lambdas Begin
// ------------------------------------------------------------------------------

(*  updateMetadata lambda - update the metadata at a given key *)
function lambdaUpdateMetadata(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {
    
    verifySenderIsAdmin(s); // check that sender is admin 

    case kycLambdaAction of [
        |   LambdaUpdateMetadata(updateMetadataParams) -> {
                
                const metadataKey   : string = updateMetadataParams.metadataKey;
                const metadataHash  : bytes  = updateMetadataParams.metadataHash;
                
                s.metadata[metadataKey] := metadataHash;
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  mistaken lambda *)
function lambdaMistakenTransfer(const kycLambdaAction : kycLambdaActionType; var s: kycStorageType) : return is
block {

    var operations : list(operation) := nil;

    case kycLambdaAction of [
        |   LambdaMistakenTransfer(destinationParams) -> {

                verifySenderIsSuperAdmin(s); 

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
// Admin Lambdas Begin
// ------------------------------------------------------------------------------

(*  setCountryTransferRule lambda *)
function lambdaSetCountryTransferRule(const kycLambdaAction : kycLambdaActionType; var s: kycStorageType) : return is
block {

    case kycLambdaAction of [
        |   LambdaSetCountryTransferRule(setCountryTransferRuleParams) -> {

                verifySenderIsAdmin(s); // check that sender is admin 

                case setCountryTransferRuleParams of [
                        AddNewCountryTransferRule(_ruleList) -> {

                            for rule in list _ruleList {
                                
                                const countryName : string = rule.country;

                                // validate country exists
                                validateInput("country", countryName, s);

                                for whitelistCountry in set rule.whitelistCountries {
                                    // validate country exists
                                    validateInput("country", whitelistCountry, s);
                                };

                                for blacklistCountry in set rule.blacklistCountries {
                                    // validate country exists
                                    validateInput("country", blacklistCountry, s);
                                };

                                const countryTransferRuleRecord : countryTransferRuleRecordType = case s.countryTransferRuleLedger[countryName] of [
                                        Some(_v) -> failwith(error_TRANSFER_RULE_ALREADY_EXISTS_FOR_COUNTRY)
                                    |   None -> record [
                                            whitelistCountries  = rule.whitelistCountries;
                                            blacklistCountries  = rule.blacklistCountries;
                                            sendingFrozen       = rule.sendingFrozen;
                                            receivingFrozen     = rule.receivingFrozen;
                                    ]
                                ];

                                // save new country transfer rule
                                s.countryTransferRuleLedger[countryName] := countryTransferRuleRecord;
                                
                            }
                        }
                    |   UpdateWhitelistCountries(_ruleList) -> {

                            for rule in list _ruleList {

                                const countryName : string      = rule.country;
                                const updateType : string       = rule.updateType;

                                // validate country exists
                                validateInput("country", countryName, s);

                                const countrySet : set(string)  = rule.countrySet;

                                var countryTransferRuleRecord : countryTransferRuleRecordType := case s.countryTransferRuleLedger[countryName] of [
                                        Some(_record) -> _record
                                    |   None          -> failwith(error_COUNTRY_TRANSFER_RULE_RECORD_NOT_FOUND)
                                ];

                                var whitelistCountries : set(string) := countryTransferRuleRecord.whitelistCountries;

                                if updateType = "add" then {
                                    for countryName in set countrySet block {
                                        // validate country exists
                                        validateInput("country", countryName, s);
                                        whitelistCountries := Set.add(countryName, whitelistCountries);
                                    };
                                } else if updateType = "remove" then {
                                    for countryName in set countrySet block {
                                        // validate country exists
                                        validateInput("country", countryName, s);
                                        whitelistCountries := Set.remove(countryName, whitelistCountries);
                                    };
                                } else failwith(error_INVALID_UPDATE_TYPE);

                                // update changes
                                countryTransferRuleRecord.whitelistCountries  := whitelistCountries;
                                s.countryTransferRuleLedger[countryName]      := countryTransferRuleRecord;

                            }

                        }
                    |   UpdateBlacklistCountries(_ruleList) -> {

                            for rule in list _ruleList {

                                const countryName : string      = rule.country;
                                const updateType : string       = rule.updateType;

                                // validate country exists
                                validateInput("country", countryName, s);

                                const countrySet : set(string)  = rule.countrySet;

                                var countryTransferRuleRecord : countryTransferRuleRecordType := case s.countryTransferRuleLedger[countryName] of [
                                        Some(_record) -> _record
                                    |   None          -> failwith(error_COUNTRY_TRANSFER_RULE_RECORD_NOT_FOUND)
                                ];

                                var blacklistCountries : set(string) := countryTransferRuleRecord.blacklistCountries;

                                if updateType = "add" then {
                                    for countryName in set countrySet block {
                                        // validate country exists
                                        validateInput("country", countryName, s);
                                        blacklistCountries := Set.add(countryName, blacklistCountries);
                                    };
                                } else if updateType = "remove" then {
                                    for countryName in set countrySet block {
                                        // validate country exists
                                        validateInput("country", countryName, s);
                                        blacklistCountries := Set.remove(countryName, blacklistCountries);
                                    };
                                } else failwith(error_INVALID_UPDATE_TYPE);

                                // update changes
                                countryTransferRuleRecord.blacklistCountries  := blacklistCountries;
                                s.countryTransferRuleLedger[countryName]      := countryTransferRuleRecord;

                            }
                        }
                    |   FreezeSending(_freezeList) -> {

                            for rule in list _freezeList {

                                const countryName : string       = rule.country;
                                const freezeBool : bool          = rule.freezeBool;

                                // validate country exists
                                validateInput("country", countryName, s);

                                var countryTransferRuleRecord : countryTransferRuleRecordType := case s.countryTransferRuleLedger[countryName] of [
                                        Some(_record) -> _record
                                    |   None          -> failwith(error_COUNTRY_TRANSFER_RULE_RECORD_NOT_FOUND)
                                ];

                                // update changes
                                countryTransferRuleRecord.sendingFrozen     := freezeBool;
                                s.countryTransferRuleLedger[countryName]    := countryTransferRuleRecord;

                            }

                        }
                    |   FreezeReceiving(_freezeList) -> {

                            for rule in list _freezeList {

                                const countryName : string       = rule.country;
                                const freezeBool : bool          = rule.freezeBool;

                                // validate country exists
                                validateInput("country", countryName, s);

                                var countryTransferRuleRecord : countryTransferRuleRecordType := case s.countryTransferRuleLedger[countryName] of [
                                        Some(_record) -> _record
                                    |   None          -> failwith(error_COUNTRY_TRANSFER_RULE_RECORD_NOT_FOUND)
                                ];

                                // update changes
                                countryTransferRuleRecord.receivingFrozen   := freezeBool;
                                s.countryTransferRuleLedger[countryName]    := countryTransferRuleRecord;
                            }

                        }
                ];
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  setKycRegistrar lambda *)
function lambdaSetKycRegistrar(const kycLambdaAction : kycLambdaActionType; var s: kycStorageType) : return is
block {

    case kycLambdaAction of [
        |   LambdaSetKycRegistrar(setKycRegistrarParams) -> {

                verifySenderIsAdmin(s); // check that sender is admin 

                const kycRegistrarName : string         = setKycRegistrarParams.name;
                const kycRegistrarAddress : address     = setKycRegistrarParams.kycRegistrarAddress;
                const kycAdminAddresses : set(address)  = setKycRegistrarParams.kycAdminAddresses;

                const kycAdminAddressesSize : nat = Set.size(kycAdminAddresses);
                if kycAdminAddressesSize = 0n then failwith(error_AT_LEAST_ONE_KYC_ADMIN_ADDRESS_REQUIRED) else skip;

                const kycRegistrarRecord : kycRegistrarRecordType = case s.kycRegistrarLedger[kycRegistrarAddress] of [
                        Some(_record) -> failwith(error_KYC_REGISTRAR_ALREADY_EXISTS)
                    |   None -> record [
                            name                    = kycRegistrarName;
                            kycAdmins               = kycAdminAddresses;
                            membersVerified         = 0n;
                            createdAt               = Mavryk.get_now();

                            setMemberIsPaused       = False;
                            freezeMemberIsPaused    = False;
                            unfreezeMemberIsPaused  = False;
                        ]
                ];

                s.kycRegistrarLedger[kycRegistrarAddress] := kycRegistrarRecord;
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  pauseKycRegistrar lambda *)
function lambdaPauseKycRegistrar(const kycLambdaAction : kycLambdaActionType; var s: kycStorageType) : return is
block {

    case kycLambdaAction of [
        |   LambdaPauseKycRegistrar(pauseKycRegistrarListParams) -> {

                verifySenderIsAdmin(s); // check that sender is admin 

                for pauseKycRegistrarParams in list pauseKycRegistrarListParams block {

                    const kycRegistrarAddress : address = pauseKycRegistrarParams.kycRegistrarAddress;
                    const pauseBool : bool              = pauseKycRegistrarParams.pauseBool;
                    const actionToPause : string        = pauseKycRegistrarParams.actionToPause;

                    var kycRegistrarRecord : kycRegistrarRecordType := case s.kycRegistrarLedger[kycRegistrarAddress] of [
                            Some(_record) -> _record
                        |   None          -> failwith(error_KYC_REGISTRAR_RECORD_NOT_FOUND)
                    ];

                    if actionToPause = "setMember" then {
                        
                        kycRegistrarRecord.setMemberIsPaused := pauseBool;

                    } else if actionToPause = "freezeMember" then {

                        kycRegistrarRecord.freezeMemberIsPaused := pauseBool;

                    } else if actionToPause = "unfreezeMember" then {

                        kycRegistrarRecord.unfreezeMemberIsPaused := pauseBool;

                    } else if actionToPause = "all" then {

                        kycRegistrarRecord.setMemberIsPaused        := pauseBool;
                        kycRegistrarRecord.freezeMemberIsPaused     := pauseBool;
                        kycRegistrarRecord.unfreezeMemberIsPaused   := pauseBool;

                    } else failwith(error_INVALID_KYC_REGISTRAR_ACTION_TO_PAUSE);

                    s.kycRegistrarLedger[kycRegistrarAddress] := kycRegistrarRecord;
                }
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  setValidInput lambda *)
function lambdaSetValidInput(const kycLambdaAction : kycLambdaActionType; var s: kycStorageType) : return is
block {

    case kycLambdaAction of [
        |   LambdaSetValidInput(setValidInputParams) -> {

                verifySenderIsAdmin(s); // check that sender is admin 

                case setValidInputParams of [
                    |   Country(_countryList) -> {

                            var currentCountrySet : set(string) := getOrCreateValidInputSet("country", s);

                            for country in list _countryList{
                                currentCountrySet := Set.add(country, currentCountrySet);
                            };

                            s.validInputLedger["country"] := currentCountrySet;

                        }
                    |   Region(_regionList) -> {

                            var currentRegionSet : set(string) := getOrCreateValidInputSet("region", s);

                            for region in list _regionList{
                                currentRegionSet := Set.add(region, currentRegionSet);
                            };

                            s.validInputLedger["region"] := currentRegionSet;

                        }
                    |   InvestorType(_investorTypeList) -> {

                            var currentInvestorTypeSet : set(string) := getOrCreateValidInputSet("investorType", s);

                            for investorType in list _investorTypeList{
                                currentInvestorTypeSet := Set.add(investorType, currentInvestorTypeSet);
                            };

                            s.validInputLedger["investorType"] := currentInvestorTypeSet;
                            
                        }
                ];
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  setWhitelist lambda *)
function lambdaSetWhitelist(const kycLambdaAction : kycLambdaActionType; var s: kycStorageType) : return is
block {

    case kycLambdaAction of [
        |   LambdaSetWhitelist(setWhitelistParams) -> {

                verifySenderIsAdmin(s); // check that sender is admin 

                case setWhitelistParams of [
                        AddToWhitelist(_addressList)        -> {
                            for address in list _addressList {
                                s.whitelistLedger[address] := unit;
                            };
                        }
                    |   RemoveFromWhitelist(_addressList)   -> {

                            for address in list _addressList {
                                remove address from map s.whitelistLedger;
                            };
                        }
                ];
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  setBlacklist lambda *)
function lambdaSetBlacklist(const kycLambdaAction : kycLambdaActionType; var s: kycStorageType) : return is
block {

    case kycLambdaAction of [
        |   LambdaSetBlacklist(setBlacklistParams) -> {

                verifySenderIsAdmin(s); // check that sender is admin 

                case setBlacklistParams of [
                        AddToBlacklist(_addressList)        -> {
                            for address in list _addressList {
                                s.blacklistLedger[address] := unit;
                            }
                        }
                    |   RemoveFromBlacklist(_addressList)   -> {

                            for address in list _addressList {
                                remove address from map s.blacklistLedger;
                            };
                        }
                ];
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Admin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// KYC Lambdas Begin
// ------------------------------------------------------------------------------

(* setMember lambda *)
function lambdaSetMember(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {

    verifySenderIsKycRegistrar(s); 
    
    case kycLambdaAction of [
        |   LambdaSetMember(setMemberParams) -> {

                case setMemberParams of [
                        AddMember(addMemberList) -> {

                            const sender : address = Mavryk.get_sender();

                            for newMember in list addMemberList {

                                const memberAddress : address = newMember.memberAddress;

                                // validate inputs
                                validateInput("country"     , newMember.country, s);
                                validateInput("region"      , newMember.region, s);
                                validateInput("investorType", newMember.investorType, s);

                                const memberRecord : memberRecordType = case s.memberLedger[memberAddress] of [
                                        Some(_record) -> failwith(error_KYC_MEMBER_ALREADY_EXISTS)
                                    |   None          -> record [
                                            country      = newMember.country;
                                            region       = newMember.region;
                                            investorType = newMember.investorType;

                                            expireAt     = Mavryk.get_now() + secondsInYear;
                                            frozen       = False;

                                            kycRegistrar = sender; 
                                        ]
                                ];

                                s.memberLedger[memberAddress] := memberRecord;

                            };

                        }
                    |   UpdateMember(updateMemberList) -> {

                            for member in list updateMemberList {

                                const memberAddress : address = member.memberAddress;

                                var memberRecord : memberRecordType := case s.memberLedger[memberAddress] of [
                                        Some(_record) -> _record
                                    |   None          -> failwith(error_KYC_MEMBER_DOES_NOT_EXIST)
                                ];

                                // todo: check valid inputs for country/region/investorType
                                case member.country of [
                                        Some(_newCountry) -> {
                                            validateInput("country", _newCountry, s);
                                            memberRecord.country := _newCountry
                                        }
                                    |   None -> skip
                                ];

                                case member.region of [
                                        Some(_newRegion) -> {
                                            validateInput("region", _newRegion, s);
                                            memberRecord.region := _newRegion
                                        }
                                    |   None -> skip
                                ];

                                case member.investorType of [
                                        Some(_newInvestorType) -> {
                                            validateInput("investorType", _newInvestorType, s);
                                            memberRecord.investorType := _newInvestorType
                                        }
                                    |   None -> skip
                                ];

                                s.memberLedger[memberAddress] := memberRecord;

                            };

                        }
                    |   RemoveMember(memberList) -> {

                            for member in list memberList {

                                // check that member exists
                                case s.memberLedger[member] of [
                                        Some(_record) -> skip
                                    |   None          -> failwith(error_KYC_MEMBER_DOES_NOT_EXIST)
                                ];

                                remove member from map s.memberLedger;

                            };

                        }
                ];

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* setRegistrarAdmin lambda *)
function lambdaSetRegistrarAdmin(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {
    
    case kycLambdaAction of [
        |   LambdaSetRegistrarAdmin(setRegistrarAdminListParams) -> {

                const sender : address = Mavryk.get_sender();

                for setRegistrarAdminParams in list setRegistrarAdminListParams {

                    const updateType : string            = setRegistrarAdminParams.updateType;
                    const adminAddress : address         = setRegistrarAdminParams.adminAddress;
                    const kycRegistrarAddress : address  = setRegistrarAdminParams.kycRegistrarAddress;

                    var kycRegistrarRecord : kycRegistrarRecordType := case s.kycRegistrarLedger[kycRegistrarAddress] of [
                            Some(_record) -> _record
                        |   None          -> failwith(error_KYC_REGISTRAR_RECORD_NOT_FOUND)
                    ];
                    const kycRegistrarAdmins : set(address) = kycRegistrarRecord.kycAdmins;

                    const senderIsMemberKycRegistrar : bool = if sender = kycRegistrarAddress then True else False;

                    // check if sender is contract admin
                    const verifyUserIsContractAdminView : option (bool) = Mavryk.call_view("verifyUserIsContractAdmin", (sender, Mavryk.get_self_address()), s.superAdmin);
                    const userIsContractAdmin : bool = case verifyUserIsContractAdminView of [
                            Some (_bool) -> _bool
                        |   None         -> False
                    ];

                    if senderIsMemberKycRegistrar or userIsContractAdmin then {
                        
                        if updateType = "update" then {

                            kycRegistrarRecord.kycAdmins := Set.add(adminAddress, kycRegistrarAdmins);

                        } else if updateType = "remove" then {

                            kycRegistrarRecord.kycAdmins := Set.remove(adminAddress, kycRegistrarAdmins);

                        } else failwith(error_INVALID_UPDATE_TYPE);

                        s.kycRegistrarLedger[kycRegistrarAddress] := kycRegistrarRecord;

                    } else failwith(error_ONLY_ADMIN_OR_KYC_REGISTRAR_OF_MEMBER_ALLOWED)
                
                };

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* freezeMember lambda *)
function lambdaFreezeMember(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {
    
    case kycLambdaAction of [
        |   LambdaFreezeMember(memberList) -> {

                const sender : address = Mavryk.get_sender();

                for member in list memberList {

                    var memberRecord : memberRecordType := case s.memberLedger[member] of [
                            Some(_record) -> _record
                        |   None          -> failwith(error_KYC_MEMBER_DOES_NOT_EXIST)
                    ];

                    const senderIsMemberKycRegistrar : bool = if sender = memberRecord.kycRegistrar then True else False;

                    // check if sender is contract admin
                    const verifyUserIsContractAdminView : option (bool) = Mavryk.call_view("verifyUserIsContractAdmin", (sender, Mavryk.get_self_address()), s.superAdmin);
                    const userIsContractAdmin : bool = case verifyUserIsContractAdminView of [
                            Some (_bool) -> _bool
                        |   None         -> False
                    ];

                    if senderIsMemberKycRegistrar or userIsContractAdmin then {
                        memberRecord.frozen := True;
                        s.memberLedger[member] := memberRecord;
                    } else failwith(error_ONLY_ADMIN_OR_KYC_REGISTRAR_OF_MEMBER_ALLOWED)
                
                };

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(* unfreezeMember lambda *)
function lambdaUnfreezeMember(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {
    
    case kycLambdaAction of [
        |   LambdaUnfreezeMember(memberList) -> {

                const sender : address = Mavryk.get_sender();

                for member in list memberList {

                    var memberRecord : memberRecordType := case s.memberLedger[member] of [
                            Some(_record) -> _record
                        |   None          -> failwith(error_KYC_MEMBER_DOES_NOT_EXIST)
                    ];

                    const senderIsMemberKycRegistrar : bool = if sender = memberRecord.kycRegistrar then True else False;

                    // check if sender is contract admin
                    const verifyUserIsContractAdminView : option (bool) = Mavryk.call_view("verifyUserIsContractAdmin", (sender, Mavryk.get_self_address()), s.superAdmin);
                    const userIsContractAdmin : bool = case verifyUserIsContractAdminView of [
                            Some (_bool) -> _bool
                        |   None         -> False
                    ];

                    if senderIsMemberKycRegistrar or userIsContractAdmin then {
                        memberRecord.frozen := False;
                        s.memberLedger[member] := memberRecord;
                    } else failwith(error_ONLY_ADMIN_OR_KYC_REGISTRAR_OF_MEMBER_ALLOWED);

                };

            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// kyc Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Pause / Break Glass Lambdas Begin
// ------------------------------------------------------------------------------

(*  pauseAll lambda *)
function lambdaPauseAll(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {

    verifySenderIsSuperAdmin(s); 

    case kycLambdaAction of [
        |   LambdaPauseAll(_parameters) -> {
              
                // set all pause configs to True
                s := pauseAllKycEntrypoints(s);
              
            }
        |   _ -> skip
    ];  

} with (noOperations, s)



(*  unpauseAll lambda *)
function lambdaUnpauseAll(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {

    verifySenderIsSuperAdmin(s); 

    case kycLambdaAction of [
        |   LambdaUnpauseAll(_parameters) -> {
                
                // set all pause configs to False
                s := unpauseAllKycEntrypoints(s);
              
            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  togglePauseEntrypoint lambda *)
function lambdaTogglePauseEntrypoint(const kycLambdaAction : kycLambdaActionType; var s : kycStorageType) : return is
block {

    verifyNoAmountSent(Unit);     // entrypoint should not receive any tez amount  
    verifySenderIsSuperAdmin(s); 

    case kycLambdaAction of [
        |   LambdaTogglePauseEntrypoint(params) -> {

                case params.targetEntrypoint of [
                        SetMember (_v)          -> s.breakGlassConfig.setMemberIsPaused             := _v
                    |   FreezeMember (_v)       -> s.breakGlassConfig.freezeMemberIsPaused          := _v
                    |   UnfreezeMember (_v)     -> s.breakGlassConfig.unfreezeMemberIsPaused        := _v
                ];
                
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Pause / Break Glass Lambdas End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
//
// kyc Lambdas End
//
// ------------------------------------------------------------------------------
