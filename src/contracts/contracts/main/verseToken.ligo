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

// FA2 Token Types
#include "../partials/contractTypes/verseTokenTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // Housekeeping Entrypoints
        SetAdmin                  of (address)
    |   UpdateWhitelistContracts  of updateWhitelistContractsType

        // Mint/Burn Entrypoints
    |   Mint                      of (address)
    |   Burn                      of (nat)
    |   Reissue                   of reissueType


type return is list (operation) * verseTokenStorageType
const noOperations : list (operation) = nil;

// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------

function checkSenderIsAdmin(const s : verseTokenStorageType) : unit is
    if Mavryk.get_sender() =/= s.admin then failwith(error_ONLY_ADMINISTRATOR_ALLOWED)
    else unit



function checkSenderIsAllowed(var s : verseTokenStorageType) : unit is 
block {
    
    // check sender is whitelisted
    if checkInWhitelistContracts(Mavryk.get_sender(), s.whitelistContracts) then skip else failwith("ONLY_WHITELISTED_CONTRACTS_ALLOWED");

} with unit 
    
// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Views Begin
//
// ------------------------------------------------------------------------------

(* View: get admin variable *)
[@view] function getAdmin(const _ : unit; var s : verseTokenStorageType) : address is
    s.admin



[@view] function maxSupply(const _ : unit; var s : verseTokenStorageType) : nat is
    s._maxSupply



[@view] function percentageInterest(const _ : unit; var s : verseTokenStorageType) : nat is
    s._percentageInterest



[@view] function description(const _ : unit; var s : verseTokenStorageType) : string is
    s._description



[@view] function location(const _ : unit; var s : verseTokenStorageType) : string is
    s._location



[@view] function value(const _ : unit; var s : verseTokenStorageType) : string is
    s._value



[@view] function other(const _ : unit; var s : verseTokenStorageType) : string is
    s._other



(* get: whitelist contracts *)
[@view] function getWhitelistContracts(const _ : unit; const s : verseTokenStorageType) : whitelistContractsType is
    s.whitelistContracts



(* get: balance View *)
[@view] function get_balance(const ledgerKey : ledgerKeyType; const s : verseTokenStorageType) : tokenBalanceType is
    case Big_map.find_opt(ledgerKey, s.ledger) of [
            Some (_v) -> _v
        |   None      -> 0n
    ]



(* owner_of
    - Given a token id (sp.TNat) allows the consumer to view the current owner of a given token id.
*)
[@view] function owner_of(const tokenId : nat; var s : verseTokenStorageType) : option(address) is
    Big_map.find_opt(tokenId, s.ownerLedger)



(* next_token_id
    - Get the next token id
*)
[@view] function next_token_id(const _ : unit; var s : verseTokenStorageType) : nat is
    s.nextTokenId



(* total_supply View *)
[@view] function total_supply(const _tokenId : nat; const s : verseTokenStorageType) : tokenBalanceType is
    case Big_map.find_opt(_tokenId, s.total_supply) of [
            Some (_v) -> _v
        |   None      -> 0n
    ]


(* get: metadata *)
[@view] function token_metadata(const tokenId : nat; const s : verseTokenStorageType) : tokenMetadataInfoType is
    case Big_map.find_opt(tokenId, s.token_metadata) of [
            Some (_metadata)  -> _metadata
        |   None -> record[
                token_id    = tokenId;
                token_info  = map[]
            ]
    ]

// ------------------------------------------------------------------------------
//
// Views End
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Entrypoints Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setAdmin entrypoint *)
function setAdmin(const newAdminAddress : address; var s : verseTokenStorageType) : return is
block {

    checkSenderIsAdmin(s);
    s.admin := newAdminAddress;

} with (noOperations, s)



(*  updateWhitelistContracts entrypoint *)
function updateWhitelistContracts(const updateWhitelistContractsTypes : updateWhitelistContractsType; var s : verseTokenStorageType) : return is
block {

    checkSenderIsAdmin(s);
    s.whitelistContracts := updateWhitelistContractsMap(updateWhitelistContractsTypes, s.whitelistContracts);
  
} with (noOperations, s)

// ------------------------------------------------------------------------------
// Housekeeping Entrypoints End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// Mint/Burn Entrypoints Begin 
// ------------------------------------------------------------------------------

(* Mint Entrypoint *)
function mint(const _to : address; var s : verseTokenStorageType) : return is
block {

    // check sender is whitelisted
    checkSenderIsAllowed(s);

    const tokenId         : tokenIdType     = s.nextTokenId;

    // check token supply
    case s.total_supply[tokenId] of [
            Some(_v) -> if _v = 0n then skip else failwith("TOTAL_SUPPLY_EXCEEDS_ONE")
        |   None     -> skip
    ];

    const ledgerKey : ledgerKeyType = record [
        owner       = _to;
        token_id    = tokenId;
    ];

    s.token_metadata[tokenId] := record [
        token_id   = tokenId;
        token_info = map["" -> s._baseTokenURI];
    ];

    s.ledger[ledgerKey]    := 1n;

    s.total_supply[tokenId] := 1n;

    s.ownerLedger[tokenId]  := _to;

} with (noOperations, s)



(* Burn Entrypoint *)
function burn(const tokenId : nat; var s : verseTokenStorageType) : return is
block {

    // check sender is whitelisted
    checkSenderIsAllowed(s);

    // check token supply
    case s.total_supply[tokenId] of [
            Some(_v) -> if _v = 1n then skip else failwith("TOTAL_SUPPLY_IS_ZERO")
        |   None     -> failwith("TOTAL_SUPPLY_NOT_FOUND")
    ];

    const ownerOfToken : address = case s.ownerLedger[tokenId] of [
            Some(_owner) -> _owner
        |   None         -> failwith("TOKEN_HAS_NO_OWNER")
    ];

    const ledgerKey : ledgerKeyType = record [
        owner       = ownerOfToken;
        token_id    = tokenId;
    ];

    s.ledger[ledgerKey]     := 0n;
    s.total_supply[tokenId] := 0n;
    s.ownerLedger[tokenId]  := burnAddress;

} with (noOperations, s)



(* Reissue Entrypoint *)
function reissue(const reissueParams : reissueType; var s : verseTokenStorageType) : return is
block {

    // check sender is whitelisted
    checkSenderIsAllowed(s);

    const _to : address     = reissueParams._to;
    const tokenId : nat     = reissueParams.tokenId;
    const tokenURI : bytes  = reissueParams.tokenURI;

    // check token supply
    case s.total_supply[tokenId] of [
            Some(_v) -> if _v = 0n then skip else failwith("TOTAL_SUPPLY_EXCEEDS_ONE")
        |   None     -> skip
    ];

    const ledgerKey : ledgerKeyType = record [
        owner       = _to;
        token_id    = tokenId;
    ];
    
    s.token_metadata[tokenId] := record [
        token_id   = tokenId;
        token_info = map["" -> tokenURI];
    ];

    s.ledger[ledgerKey]    := 1n;

    s.total_supply[tokenId] := 1n;

    s.ownerLedger[tokenId]  := _to;

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Mint/Burn Entrypoints End 
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Entrypoints End
//
// ------------------------------------------------------------------------------


(* main entrypoint *)
function main (const action : action; const s : verseTokenStorageType) : return is
block{

    verifyNoAmountSent(Unit); // // entrypoints should not receive any tez amount  

} with(
    
    case action of [

            // Housekeeping Entrypoints
            SetAdmin (parameters)                   -> setAdmin(parameters, s)
        |   UpdateWhitelistContracts (parameters)   -> updateWhitelistContracts(parameters, s)

            // Mint/Burn Entrypoints
        |   Mint (parameters)                       -> mint(parameters, s)
        |   Burn (parameters)                       -> burn(parameters, s)
        |   Reissue (parameters)                    -> reissue(parameters, s)

    ]

)
