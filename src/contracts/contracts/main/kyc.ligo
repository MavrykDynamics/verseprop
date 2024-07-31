// ------------------------------------------------------------------------------
// Error Codes
// ------------------------------------------------------------------------------

// Error Codes
#include "../partials/errors.ligo"

// ------------------------------------------------------------------------------
// Shared Helpers and Types
// ------------------------------------------------------------------------------

// Shared Helpers
#include "../partials/shared/sharedHelpers.ligo"

// Transfer Helpers
#include "../partials/shared/transferHelpers.ligo"

// Constants
#include "../partials/shared/constants.ligo"

// ------------------------------------------------------------------------------
// Contract Types
// ------------------------------------------------------------------------------

// KYC Token Types
#include "../partials/contractTypes/kycTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // SuperAdmin Entrypoints
        SetSuperAdmin               of (address)
    |   ClaimSuperAdmin             of (unit)

        // Admin Entrypoints
    |   SetCountryTransferRule      of setCountryTransferRuleActionType
    |   SetKycRegistrar             of setKycRegistrarActionType
    |   PauseKycRegistrar           of pauseKycRegistrarActionType
    |   SetValidInput               of setValidInputActionType
    |   SetWhitelist                of setWhitelistActionType
    |   SetBlacklist                of setBlacklistActionType

        // Housekeeping Entrypoints
    |   UpdateMetadata              of updateMetadataType
    |   MistakenTransfer            of transferActionType

        // Pause / Break Glass Entrypoints
    |   PauseAll                    of (unit)
    |   UnpauseAll                  of (unit)
    |   TogglePauseEntrypoint       of kycTogglePauseEntrypointType

        // KYC Registrar Entrypoints
    |   SetMember                   of setMemberActionType
    |   SetRegistrarAdmin           of setRegistrarAdminActionType
    |   FreezeMember                of list(address)
    |   UnfreezeMember              of list(address)
    
        // Lambda Entrypoints
    |   SetLambda                   of setLambdaType
    
    
type return is list (operation) * kycStorageType
const noOperations : list (operation) = nil;


// kyc contract methods lambdas
type kycUnpackLambdaFunctionType is (kycLambdaActionType * kycStorageType) -> return


// ------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------

// kyc Helpers:
#include "../partials/contractHelpers/kycHelpers.ligo"

// ------------------------------------------------------------------------------
// Views
// ------------------------------------------------------------------------------

// kyc Views:
#include "../partials/contractViews/kycViews.ligo"

// ------------------------------------------------------------------------------
// Lambdas
// ------------------------------------------------------------------------------

// kyc Lambdas:
#include "../partials/contractLambdas/kycLambdas.ligo"

// ------------------------------------------------------------------------------
// Entrypoints
// ------------------------------------------------------------------------------

// kyc Entrypoints:
#include "../partials/contractEntrypoints/kycEntrypoints.ligo"

// ------------------------------------------------------------------------------

(* main entrypoint *)
function main (const action : action; const s : kycStorageType) : return is

    case action of [

            // Admin Entrypoints
            SetSuperAdmin(parameters)             -> setSuperAdmin(parameters, s)
        |   ClaimSuperAdmin(_parameters)          -> claimSuperAdmin(s)

            // Admin Entrypoints
        |   SetCountryTransferRule(parameters)    -> setCountryTransferRule(parameters, s)
        |   SetKycRegistrar(parameters)           -> setKycRegistrar(parameters, s)
        |   PauseKycRegistrar(parameters)         -> pauseKycRegistrar(parameters, s)
        |   SetValidInput(parameters)             -> setValidInput(parameters, s)
        |   SetWhitelist(parameters)              -> setWhitelist(parameters, s)
        |   SetBlacklist(parameters)              -> setBlacklist(parameters, s)

            // Housekeeping Entrypoints
        |   UpdateMetadata(parameters)            -> updateMetadata(parameters, s)
        |   MistakenTransfer(parameters)          -> mistakenTransfer(parameters, s)

            // Pause / Break Glass Entrypoints
        |   PauseAll(_parameters)                 -> pauseAll(s)
        |   UnpauseAll(_parameters)               -> unpauseAll(s)
        |   TogglePauseEntrypoint(parameters)     -> togglePauseEntrypoint(parameters, s)

            // KYC Registrar Entrypoints
        |   SetMember(parameters)                 -> setMember(parameters, s)
        |   SetRegistrarAdmin(parameters)         -> setRegistrarAdmin(parameters, s)
        |   FreezeMember(parameters)              -> freezeMember(parameters, s)
        |   UnfreezeMember(parameters)            -> unfreezeMember(parameters, s)
        
            // Lambda Entrypoints
        |   SetLambda(parameters)                 -> setLambda(parameters, s)
    ]

