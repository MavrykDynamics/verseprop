





error_ENTRYPOINT_SHOULD_NOT_RECEIVE_TEZ                                                                 = 0
error_INCORRECT_TEZ_FEE                                                                                 = 1

error_LAMBDA_NOT_FOUND                                                                                  = 2
error_UNABLE_TO_UNPACK_LAMBDA                                                                           = 3
error_UNABLE_TO_UNPACK_ACTION_PARAMETER                                                                 = 4

error_CALCULATION_ERROR                                                                                 = 5
error_CONFIG_VALUE_ERROR                                                                                = 6
error_CONFIG_VALUE_TOO_HIGH                                                                             = 7
error_CONFIG_VALUE_TOO_LOW                                                                              = 8
error_INDEX_OUT_OF_BOUNDS                                                                               = 9
error_INVALID_BLOCKS_PER_MINUTE                                                                         = 10
error_WRONG_INPUT_PROVIDED                                                                              = 11
error_WRONG_TOKEN_TYPE_PROVIDED                                                                         = 12
error_TOKEN_NOT_WHITELISTED                                                                             = 13

error_ONLY_SUPER_ADMINISTRATOR_ALLOWED                                                                  = 14
error_ONLY_ADMINISTRATOR_ALLOWED                                                                        = 15
error_ONLY_SELF_ALLOWED                                                                                 = 16
error_ONLY_WHITELISTED_ADDRESSES_ALLOWED                                                                = 17

error_SPECIFIED_ENTRYPOINT_NOT_FOUND                                                                    = 18
error_SET_ADMIN_ENTRYPOINT_NOT_FOUND                                                                    = 19
error_SET_LAMBDA_ENTRYPOINT_NOT_FOUND                                                                   = 20
error_SET_PRODUCT_LAMBDA_ENTRYPOINT_NOT_FOUND                                                           = 21
error_PAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                    = 22
error_UNPAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                  = 23
error_UPDATE_METADATA_ENTRYPOINT_NOT_FOUND                                                              = 24
error_UPDATE_BLOCKS_PER_MIN_ENTRYPOINT_NOT_FOUND                                                        = 25
error_TRANSFER_ENTRYPOINT_IN_FA12_CONTRACT_NOT_FOUND                                                    = 26
error_TRANSFER_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                     = 27








error_KYC_CONTRACT_NOT_FOUND                                                                             = 28

error_SET_WHITELIST_ENTRYPOINT_IN_KYC_CONTRACT_NOT_FOUND                                                 = 29

error_KYC_MEMBER_DOES_NOT_EXIST                                                                          = 30
error_FROM_KYC_MEMBER_DOES_NOT_EXIST                                                                     = 31
error_TO_KYC_MEMBER_DOES_NOT_EXIST                                                                       = 32
error_KYC_MEMBER_ALREADY_EXISTS                                                                          = 33

error_COUNTRY_TRANSFER_RULE_RECORD_NOT_FOUND                                                             = 34
error_TRANSFER_RULE_ALREADY_EXISTS_FOR_COUNTRY                                                           = 35

error_KYC_REGISTRAR_ALREADY_EXISTS                                                                       = 36
error_ONLY_KYC_REGISTRAR_ALLOWED                                                                         = 37
error_VALID_INPUT_SET_NOT_FOUND                                                                          = 38
error_INVALID_INPUT                                                                                      = 39
error_ONLY_ADMIN_OR_KYC_REGISTRAR_ALLOWED                                                                = 40
error_ONLY_ADMIN_OR_KYC_REGISTRAR_OF_MEMBER_ALLOWED                                                      = 41

error_KYC_REGISTRAR_RECORD_NOT_FOUND                                                                     = 42

error_AT_LEAST_ONE_KYC_ADMIN_ADDRESS_REQUIRED                                                            = 43
error_INVALID_KYC_REGISTRAR_ACTION_TO_PAUSE                                                              = 44








error_SUPER_ADMIN_CONTRACT_NOT_FOUND                                                                     = 45

error_ADDRESS_NOT_GENERAL_ADMIN                                                                          = 46
error_ADDRESS_IS_ALREADY_GENERAL_ADMIN                                                                   = 47
error_ONLY_GENERAL_ADMIN_ALLOWED                                                                         = 48
error_ONLY_CONTRACT_ADMIN_ALLOWED                                                                        = 49
error_INVALID_CONFIG_ACTION                                                                              = 50

error_ADDRESS_IS_ALREADY_CONTRACT_ADMIN                                                                  = 51
error_SIGNATORY_ACTION_ALREADY_SIGNED_BY_SENDER                                                          = 52

error_SIGNATORY_NOT_FOUND                                                                                = 53
error_SIGNATORY_ACTION_NOT_FOUND                                                                         = 54
error_SIGNATORY_ACTION_FLUSHED                                                                           = 55
error_SIGNATORY_ACTION_EXECUTED                                                                          = 56
error_SIGNATORY_ACTION_EXPIRED                                                                           = 57

error_SIGNATORY_ACTION_EXPIRY_IN_SECONDS_TOO_LOW_ERROR                                                   = 58
error_SIGNATORY_ALREADY_EXISTS                                                                           = 59
error_ADDRESS_IS_ALREADY_SIGNATORY                                                                       = 60
error_SIGNATORY_ADDRESS_NOT_FOUND                                                                        = 61
error_SIGNATORY_THRESHOLD_ERROR                                                                          = 62
error_CONTRACT_ADMIN_ADDRESS_NOT_FOUND                                                                   = 63
error_SIGNATORY_ACTION_PARAMETER_NOT_FOUND                                                               = 64

error_ONLY_SIGNATORIES_ALLOWED                                                                           = 65
error_SET_SUPER_ADMIN_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                   = 66
error_CLAIM_SUPER_ADMIN_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                 = 67
error_SET_TOKEN_KYC_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                     = 68
error_KILL_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                              = 69

error_ONLY_SELF_ADDRESS_ALLOWED                                                                          = 70







error_ADMIN_NOT_FOUND                                                                                   = 71
error_NOT_ADMIN                                                                                         = 72
error_NOT_SUPER_ADMIN                                                                                   = 73
error_NO_NEW_SUPER_ADMIN_FOUND                                                                          = 74
error_SENDER_IS_NOT_NEW_SUPER_ADMIN                                                                     = 75

error_TOKEN_EXISTS                                                                                      = 76
error_TOKEN_UNDEFINED                                                                                   = 77
error_TOKEN_PAUSED                                                                                      = 78

error_USER_NOT_FOUND                                                                                    = 79
error_CANNOT_TRANSFER                                                                                   = 80
error_INSUFFICIENT_BALANCE                                                                              = 81

error_VIEW_IS_TRANSFER_VALID_NOT_FOUND                                                                  = 82
error_INVALID_START_COUNTER                                                                             = 83
error_START_COUNTER_SNAPSHOT_TIMESTAMP_GREATER_THAN_BALANCE_TIMESTAMP                                   = 84


error_TRANSFER_ENTRYPOINT_IN_CONTRACT_NOT_FOUND                                                         = 85
error_GET_GENERAL_CONTRACT_OPT_VIEW_IN_GOVERNANCE_CONTRACT_NOT_FOUND                                    = 86
error_ONLY_ADMINISTRATOR_OR_GOVERNANCE_ALLOWED                                                          = 87
error_ONLY_SELF_OR_SPECIFIED_ADDRESS_ALLOWED                                                            = 88
error_INVALID_UPDATE_TYPE                                                                               = 89
