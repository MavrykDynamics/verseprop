// ------------------------------------------------------------------------------
//
// General Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_ENTRYPOINT_SHOULD_NOT_RECEIVE_TEZ                                                                 = 0n;
[@inline] const error_INCORRECT_TEZ_FEE                                                                                 = 1n;

[@inline] const error_LAMBDA_NOT_FOUND                                                                                  = 2n;
[@inline] const error_UNABLE_TO_UNPACK_LAMBDA                                                                           = 3n;
[@inline] const error_UNABLE_TO_UNPACK_ACTION_PARAMETER                                                                 = 4n;

[@inline] const error_CALCULATION_ERROR                                                                                 = 5n;
[@inline] const error_CONFIG_VALUE_ERROR                                                                                = 6n;
[@inline] const error_CONFIG_VALUE_TOO_HIGH                                                                             = 7n;
[@inline] const error_CONFIG_VALUE_TOO_LOW                                                                              = 8n;
[@inline] const error_INDEX_OUT_OF_BOUNDS                                                                               = 9n;
[@inline] const error_INVALID_BLOCKS_PER_MINUTE                                                                         = 10n;
[@inline] const error_WRONG_INPUT_PROVIDED                                                                              = 11n;
[@inline] const error_WRONG_TOKEN_TYPE_PROVIDED                                                                         = 12n;
[@inline] const error_TOKEN_NOT_WHITELISTED                                                                             = 13n;

[@inline] const error_ONLY_SUPER_ADMINISTRATOR_ALLOWED                                                                  = 14n;
[@inline] const error_ONLY_ADMINISTRATOR_ALLOWED                                                                        = 15n;
[@inline] const error_ONLY_SELF_ALLOWED                                                                                 = 16n;
[@inline] const error_ONLY_WHITELISTED_ADDRESSES_ALLOWED                                                                = 17n;

[@inline] const error_SPECIFIED_ENTRYPOINT_NOT_FOUND                                                                    = 18n;
[@inline] const error_SET_ADMIN_ENTRYPOINT_NOT_FOUND                                                                    = 19n;
[@inline] const error_SET_LAMBDA_ENTRYPOINT_NOT_FOUND                                                                   = 20n;
[@inline] const error_SET_PRODUCT_LAMBDA_ENTRYPOINT_NOT_FOUND                                                           = 21n;
[@inline] const error_PAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                    = 22n;
[@inline] const error_UNPAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                  = 23n;
[@inline] const error_UPDATE_METADATA_ENTRYPOINT_NOT_FOUND                                                              = 24n;
[@inline] const error_UPDATE_BLOCKS_PER_MIN_ENTRYPOINT_NOT_FOUND                                                        = 25n;
[@inline] const error_TRANSFER_ENTRYPOINT_IN_FA12_CONTRACT_NOT_FOUND                                                    = 26n;
[@inline] const error_TRANSFER_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                     = 27n;


// ------------------------------------------------------------------------------
//
// KYC Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_KYC_CONTRACT_NOT_FOUND                                                                             = 28n;

[@inline] const error_SET_WHITELIST_ENTRYPOINT_IN_KYC_CONTRACT_NOT_FOUND                                                 = 29n;

[@inline] const error_KYC_MEMBER_DOES_NOT_EXIST                                                                          = 30n;
[@inline] const error_FROM_KYC_MEMBER_DOES_NOT_EXIST                                                                     = 31n;
[@inline] const error_TO_KYC_MEMBER_DOES_NOT_EXIST                                                                       = 32n;
[@inline] const error_KYC_MEMBER_ALREADY_EXISTS                                                                          = 33n;

[@inline] const error_COUNTRY_TRANSFER_RULE_RECORD_NOT_FOUND                                                             = 34n;
[@inline] const error_TRANSFER_RULE_ALREADY_EXISTS_FOR_COUNTRY                                                           = 35n;

[@inline] const error_KYC_REGISTRAR_ALREADY_EXISTS                                                                       = 36n;
[@inline] const error_ONLY_KYC_REGISTRAR_ALLOWED                                                                         = 37n;
[@inline] const error_VALID_INPUT_SET_NOT_FOUND                                                                          = 38n;
[@inline] const error_INVALID_INPUT                                                                                      = 39n;
[@inline] const error_ONLY_ADMIN_OR_KYC_REGISTRAR_ALLOWED                                                                = 40n;
[@inline] const error_ONLY_ADMIN_OR_KYC_REGISTRAR_OF_MEMBER_ALLOWED                                                      = 41n;

[@inline] const error_KYC_REGISTRAR_RECORD_NOT_FOUND                                                                     = 42n;

[@inline] const error_AT_LEAST_ONE_KYC_ADMIN_ADDRESS_REQUIRED                                                            = 43n;
[@inline] const error_INVALID_KYC_REGISTRAR_ACTION_TO_PAUSE                                                              = 44n;


// ------------------------------------------------------------------------------
//
// Super Admin Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_SUPER_ADMIN_CONTRACT_NOT_FOUND                                                                     = 45n;

[@inline] const error_ADDRESS_NOT_GENERAL_ADMIN                                                                          = 46n;
[@inline] const error_ADDRESS_IS_ALREADY_GENERAL_ADMIN                                                                   = 47n;
[@inline] const error_ONLY_GENERAL_ADMIN_ALLOWED                                                                         = 48n;
[@inline] const error_ONLY_CONTRACT_ADMIN_ALLOWED                                                                        = 49n;
[@inline] const error_INVALID_CONFIG_ACTION                                                                              = 50n;

[@inline] const error_ADDRESS_IS_ALREADY_CONTRACT_ADMIN                                                                  = 51n;
[@inline] const error_SIGNATORY_ACTION_ALREADY_SIGNED_BY_SENDER                                                          = 52n;

[@inline] const error_SIGNATORY_NOT_FOUND                                                                                = 53n;
[@inline] const error_SIGNATORY_ACTION_NOT_FOUND                                                                         = 54n;
[@inline] const error_SIGNATORY_ACTION_FLUSHED                                                                           = 55n;
[@inline] const error_SIGNATORY_ACTION_EXECUTED                                                                          = 56n;
[@inline] const error_SIGNATORY_ACTION_EXPIRED                                                                           = 57n;

[@inline] const error_SIGNATORY_ACTION_EXPIRY_IN_SECONDS_TOO_LOW_ERROR                                                   = 58n;
[@inline] const error_SIGNATORY_ALREADY_EXISTS                                                                           = 59n;
[@inline] const error_ADDRESS_IS_ALREADY_SIGNATORY                                                                       = 60n;
[@inline] const error_SIGNATORY_ADDRESS_NOT_FOUND                                                                        = 61n;
[@inline] const error_SIGNATORY_THRESHOLD_ERROR                                                                          = 62n;
[@inline] const error_CONTRACT_ADMIN_ADDRESS_NOT_FOUND                                                                   = 63n;
[@inline] const error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND                                                               = 64n;

[@inline] const error_ONLY_SIGNATORIES_ALLOWED                                                                           = 65n;
[@inline] const error_SET_SUPER_ADMIN_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                   = 66n;
[@inline] const error_CLAIM_SUPER_ADMIN_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                 = 67n;
[@inline] const error_SET_TOKEN_KYC_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                     = 68n;
[@inline] const error_KILL_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                              = 69n;

[@inline] const error_ONLY_SELF_ADDRESS_ALLOWED                                                                          = 70n;

// ------------------------------------------------------------------------------
//
// RWA Token Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_ADMIN_NOT_FOUND                                                                                   = 71n;
[@inline] const error_NOT_ADMIN                                                                                         = 72n;
[@inline] const error_NOT_SUPER_ADMIN                                                                                   = 73n;
[@inline] const error_NO_NEW_SUPER_ADMIN_FOUND                                                                          = 74n;
[@inline] const error_SENDER_IS_NOT_NEW_SUPER_ADMIN                                                                     = 75n;

[@inline] const error_TOKEN_EXISTS                                                                                      = 76n;
[@inline] const error_TOKEN_UNDEFINED                                                                                   = 77n;
[@inline] const error_TOKEN_PAUSED                                                                                      = 78n;

[@inline] const error_USER_NOT_FOUND                                                                                    = 79n;
[@inline] const error_CANNOT_TRANSFER                                                                                   = 80n;
[@inline] const error_INSUFFICIENT_BALANCE                                                                              = 81n;

[@inline] const error_VIEW_IS_TRANSFER_VALID_NOT_FOUND                                                                  = 82n;
[@inline] const error_INVALID_START_COUNTER                                                                             = 83n;
[@inline] const error_START_COUNTER_SNAPSHOT_TIMESTAMP_GREATER_THAN_BALANCE_TIMESTAMP                                   = 84n;

// missing shared helpers errors
[@inline] const error_TRANSFER_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                         = 85n;
[@inline] const error_GET_GENERAL_CONTRACT_OPT_VIEW_IN_GOVERNANCE_CONTRACT_NOT_FOUND                                    = 86n;
[@inline] const error_ONLY_ADMINISTRATOR_OR_GOVERNANCE_ALLOWED                                                          = 87n;
[@inline] const error_ONLY_SELF_OR_SPECIFIED_ADDRESS_ALLOWED                                                            = 88n;
[@inline] const error_INVALID_UPDATE_TYPE                                                                               = 89n;

[@inline] const error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                         = 90n;
[@inline] const error_BURN_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                         = 91n;

[@inline] const error_ONLY_MANAGER_ALLOWED                                                                              = 92n;
[@inline] const error_ONLY_ADMIN_OR_MANAGER_ALLOWED                                                                     = 93n;


