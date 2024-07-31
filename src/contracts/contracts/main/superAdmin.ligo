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

// superAdmin Types
#include "../partials/contractTypes/superAdminTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // SuperAdmin Entrypoints
    |   SetSuperAdmin               of setSuperAdminActionType
    |   ClaimSuperAdmin             of list(address)

        // Set Admin Entrypoints
    |   SetGeneralAdmin             of list(address)
    |   RemoveGeneralAdmin          of list(address)
    |   SetContractAdmin            of setContractAdminActionType
    |   RemoveContractAdmin         of setContractAdminActionType
    |   UpdateConfig                of superAdminUpdateConfigParamsType

        // Signatory Entrypoints
    |   AddSignatory                of list(address)
    |   RemoveSignatory             of list(address)

        // Token Entrypoints
    |   SetTokenKyc                 of setTokenKycActionType
    |   KillToken                   of list(address)

        // Treasury Transfer Entrypoints
    |   Transfer                    of superAdminTransferActionType

        // Housekeeping Entrypoints
    |   UpdateMetadata              of updateMetadataType
    |   MistakenTransfer            of transferActionType

        // Signing Entrypoints
    |   FlushAction                 of list(nat)
    |   SignAction                  of list(nat)

        // Lambda Entrypoints
    |   SetLambda                   of setLambdaType
    
    
type return is list (operation) * superAdminStorageType
const noOperations : list (operation) = nil;


// superAdmin contract methods lambdas
type superAdminUnpackLambdaFunctionType is (superAdminLambdaActionType * superAdminStorageType) -> return


// ------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------

// superAdmin Helpers:
#include "../partials/contractHelpers/superAdminHelpers.ligo"

// ------------------------------------------------------------------------------
// Views
// ------------------------------------------------------------------------------

// superAdmin Views:
#include "../partials/contractViews/superAdminViews.ligo"

// ------------------------------------------------------------------------------
// Lambdas
// ------------------------------------------------------------------------------

// superAdmin Lambdas:
#include "../partials/contractLambdas/superAdminLambdas.ligo"

// ------------------------------------------------------------------------------
// Entrypoints
// ------------------------------------------------------------------------------

// superAdmin Entrypoints:
#include "../partials/contractEntrypoints/superAdminEntrypoints.ligo"

// ------------------------------------------------------------------------------

(* main entrypoint *)
function main (const action : action; const s : superAdminStorageType) : return is

    case action of [

            // SuperAdmin Entrypoints
        |   SetSuperAdmin(parameters)             -> setSuperAdmin(parameters, s)
        |   ClaimSuperAdmin(parameters)          -> claimSuperAdmin(parameters, s)

            // Set Admin Entrypoints
        |   SetGeneralAdmin(parameters)           -> setGeneralAdmin(parameters, s)
        |   RemoveGeneralAdmin(parameters)        -> removeGeneralAdmin(parameters, s)
        |   SetContractAdmin(parameters)          -> setContractAdmin(parameters, s)
        |   RemoveContractAdmin(parameters)       -> removeContractAdmin(parameters, s)

            // Signatory Entrypoints
        |   AddSignatory(parameters)              -> addSignatory(parameters, s)
        |   RemoveSignatory(parameters)           -> removeSignatory(parameters, s)

            // Token Entrypoints
        |   SetTokenKyc(params)                   -> setTokenKyc(params, s)
        |   KillToken(params)                     -> killToken(params, s)

            // Treasury Transfer Entrypoints
        |   Transfer(parameters)                  -> transfer(parameters, s)
        
            // Housekeeping Entrypoints
        |   UpdateMetadata(parameters)            -> updateMetadata(parameters, s)
        |   UpdateConfig(parameters)              -> updateConfig(parameters, s)
        |   MistakenTransfer(parameters)          -> mistakenTransfer(parameters, s)

            // Signatory Entrypoints
        |   FlushAction(parameters)               -> flushAction(parameters, s)
        |   SignAction(parameters)                -> signAction(parameters, s)

            // Lambda Entrypoints
        |   SetLambda(parameters)                 -> setLambda(parameters, s)
    ]

