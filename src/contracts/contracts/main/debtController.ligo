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

// RWA Token Types
#include "../partials/contractTypes/rwaTokenTypes.ligo"

// DebtController Types
#include "../partials/contractTypes/debtControllerTypes.ligo"

// ------------------------------------------------------------------------------

type action is

    |   Default                     of unit

        // Admin Entrypoints
    |   AddManager                  of (address)
    |   RemoveManager               of (address)
    |   AddAdmin                    of (address)
    |   RemoveAdmin                 of (address)
    |   UpdateMetadata              of updateMetadataType

        // Admin Debt Controller Entrypoints
    |   AddDebt                     of addDebtActionType
    |   UpdateDebt                  of updateDebtActionType
    |   SetInvestment               of setInvestmentActionType
    |   SetFeeWallet                of (address)
    
        // Debt Controller Entrypoints
    |   CreateDebt                  of createDebtActionType
    |   DisburseLoan                of (nat)
    |   ReturnDeposit               of (nat)
    |   AddDeposit                  of addDepositActionType
    |   WithdrawDeposit             of withdrawDepositActionType
    |   PayOffDebt                  of (nat)

        // Lambda Entrypoints
    |   SetLambda                   of setLambdaType
    
    
type return is list (operation) * debtControllerStorageType
const noOperations : list (operation) = nil;


// DebtController contract methods lambdas
type debtControllerUnpackLambdaFunctionType is (debtControllerLambdaActionType * debtControllerStorageType) -> return


// ------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------

// DebtController Helpers:
#include "../partials/contractHelpers/debtControllerHelpers.ligo"

// ------------------------------------------------------------------------------
// Views
// ------------------------------------------------------------------------------

// DebtController Views:
#include "../partials/contractViews/debtControllerViews.ligo"

// ------------------------------------------------------------------------------
// Lambdas
// ------------------------------------------------------------------------------

// DebtController Lambdas:
#include "../partials/contractLambdas/debtControllerLambdas.ligo"

// ------------------------------------------------------------------------------
// Entrypoints
// ------------------------------------------------------------------------------

// DebtController Entrypoints:
#include "../partials/contractEntrypoints/debtControllerEntrypoints.ligo"

// ------------------------------------------------------------------------------


(* main entrypoint *)
function main (const action : action; const s : debtControllerStorageType) : return is

    case action of [

        |   Default(_params)                      -> ((nil : list(operation)), s)

            // Admin Entrypoints
        |   AddManager(parameters)                -> addManager(parameters, s)
        |   RemoveManager(_parameters)            -> removeManager(s)
        |   AddAdmin(parameters)                  -> addAdmin(parameters, s)
        |   RemoveAdmin(parameters)               -> removeAdmin(parameters, s)
        |   UpdateMetadata(parameters)            -> updateMetadata(parameters, s)

            // Debt Controller Admin Entrypoints
        |   AddDebt(parameters)                   -> addDebt(parameters, s)
        |   UpdateDebt(parameters)                -> updateDebt(parameters, s)
        |   SetInvestment(parameters)             -> setInvestment(parameters, s)
        |   SetFeeWallet(parameters)              -> setFeeWallet(parameters, s)

            // Debt Controller Entrypoints
        |   CreateDebt(parameters)                -> createDebt(parameters, s)
        |   DisburseLoan(parameters)              -> disburseLoan(parameters, s)
        |   ReturnDeposit(parameters)             -> returnDeposit(parameters, s)
        |   AddDeposit(parameters)                -> addDeposit(parameters, s)
        |   WithdrawDeposit(parameters)           -> withdrawDeposit(parameters, s)
        |   PayOffDebt(parameters)                -> payOffDebt(parameters, s)

            // Lambda Entrypoints
        |   SetLambda(parameters)                 -> setLambda(parameters, s)
    ]

