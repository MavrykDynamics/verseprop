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

// KYC Types
#include "../partials/contractTypes/kycTypes.ligo"

// RWA Token Types
#include "../partials/contractTypes/rwaTokenNonFungibleTypes.ligo"

// ------------------------------------------------------------------------------

type action is

        // SuperAdmin Entrypoints
    |   SetSuperAdmin             of (address)
    |   ClaimSuperAdmin           of unit
    |   SetTokenKyc               of (address)
    |   Kill                      of unit 
        
        // Admin Entrypoints
    |   SetTokenMetadata          of list(tokenMetadataType)
    |   Mint                      of list(mintType)
    |   Burn                      of list(burnType)
    |   Pause                     of unit
    |   Unpause                   of unit

        // FA2 Entrypoints
    |   Transfer                  of fa2TransferType
    |   Balance_of                of balanceOfType
    |   Update_operators          of updateOperatorsType
    
    
type return is list (operation) * rwaTokenStorageType
const noOperations : list (operation) = nil;


// ------------------------------------------------------------------------------
// Admin Helper Functions Begin
// ------------------------------------------------------------------------------

function verifySenderIsSuperAdmin(const s : rwaTokenStorageType) : unit is 
block {

    const sender : address = Mavryk.get_sender();
    if sender = s.superAdmin then skip else failwith(error_NOT_SUPER_ADMIN);

} with unit



function verifySenderIsAdmin(const s : rwaTokenStorageType) : unit is 
block {

    const sender : address = Mavryk.get_sender();

    // check if general admin
    const verifyUserIsGeneralAdminView : option (bool) = Mavryk.call_view("verifyUserIsGeneralAdmin", sender, s.superAdmin);
    const userIsGeneralAdmin : bool = case verifyUserIsGeneralAdminView of [
            Some (_bool) -> _bool
        |   None         -> failwith("error_VIEW_VERIFY_USER_IS_GENERAL_ADMIN_NOT_FOUND")
    ];

    // check if contract admin
    const verifyUserIsContractAdminView : option (bool) = Mavryk.call_view("verifyUserIsContractAdmin", (sender, Mavryk.get_self_address()), s.superAdmin);
    const userIsContractAdmin : bool = case verifyUserIsContractAdminView of [
            Some (_bool) -> _bool
        |   None         -> failwith("error_VIEW_VERIFY_USER_IS_CONTRACT_ADMIN_NOT_FOUND")
    ];

    // pass if user is general admin or contract admin
    if userIsGeneralAdmin or userIsContractAdmin then skip else failwith(error_NOT_ADMIN);

} with unit



function verifyTokenIsDefined(const tokenId : nat; const s : rwaTokenStorageType) : unit is
block {

    case s.token_metadata[tokenId] of [
            Some (_v) -> skip
        |   None      -> failwith(error_TOKEN_UNDEFINED)
    ];

} with unit



function verifyTokenIsNotPaused(const s : rwaTokenStorageType) : unit is
block {

    if s.isPaused then failwith("error_TOKEN_PAUSED") else skip;

} with unit



function verifySufficientBalance(const ledger_key : ledgerKeyType; const amount : nat; const s : rwaTokenStorageType) : unit is
block {

    const balance : nat = case s.ledger[ledger_key] of [
            Some(_v) -> _v
        |   None     -> 0n
    ];

    if balance < amount then failwith(error_INSUFFICIENT_BALANCE) else skip;

} with unit



function takeUserBalanceSnapshot(const tokenId : nat; const user : address; const userTokenChunk : nat; const userTokenCounter : nat; const userTokenBalance : nat; var s : rwaTokenStorageType) : rwaTokenStorageType is 
block {

    // take new snapshot
    const snapshotKey : (nat * address * nat)       = (tokenId, user, userTokenChunk);
    const snapshotValue : (nat * timestamp)         = (userTokenBalance, Mavryk.get_now());
    var snapshotChunkMap : snapshotMapChunkType    := case s.snapshotLedger[snapshotKey] of [
            Some(_map) -> _map
        |   None       -> (map[] : snapshotMapChunkType)
    ];

    snapshotChunkMap[userTokenCounter]  := snapshotValue;
    s.snapshotLedger[snapshotKey]       := snapshotChunkMap;
    
} with s

// ------------------------------------------------------------------------------
// Admin Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// FA2 Helper Functions Begin
// ------------------------------------------------------------------------------

function verifyIsOwner(const owner : ownerType) : unit is
    if Mavryk.get_sender() =/= owner then failwith("FA2_NOT_OWNER")
    else unit



function verifySenderIsOwnerOrOperator(const owner : ownerType; const token_id : tokenIdType; const operators : operatorsType) : unit is
    if owner = Mavryk.get_sender() or Big_map.mem((owner, Mavryk.get_sender(), token_id), operators) then unit
    else failwith ("FA2_NOT_OPERATOR")



// mergeOperations helper function - used in transfer entrypoint
function mergeOperations(const first : list (operation); const second : list (operation)) : list (operation) is 
List.fold( 
    function(const operations : list(operation); const operation : operation) : list(operation) is operation # operations,
    first,
    second
)



// addOperator helper function - used in update_operators entrypoint
function addOperator(const operatorParameter : operatorParameterType; const operators : operatorsType; const s : rwaTokenStorageType) : operatorsType is
block{

    const owner     : ownerType     = operatorParameter.owner;
    const operator  : operatorType  = operatorParameter.operator;
    const token_id  : tokenIdType   = operatorParameter.token_id;

    verifyTokenIsDefined(token_id, s);

    verifyIsOwner(owner);

    const operatorKey : (ownerType * operatorType * tokenIdType) = (owner, operator, token_id)

} with(Big_map.update(operatorKey, Some (unit), operators))



// removeOperator helper function - used in update_operators entrypoint
function removeOperator(const operatorParameter : operatorParameterType; const operators : operatorsType; const s : rwaTokenStorageType) : operatorsType is
block{

    const owner     : ownerType     = operatorParameter.owner;
    const operator  : operatorType  = operatorParameter.operator;
    const token_id  : tokenIdType   = operatorParameter.token_id;

    verifyTokenIsDefined(token_id, s);
    
    verifyIsOwner(owner);

    const operatorKey : (ownerType * operatorType * tokenIdType) = (owner, operator, token_id)

} with(Big_map.remove(operatorKey, operators))

// ------------------------------------------------------------------------------
// FA2 Helper Functions End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Helper Functions End
//
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
//
// Views Begin
//
// ------------------------------------------------------------------------------

(* total_supply
    - Given a token id allows the consumer to view the current total supply.
*)
[@view] function total_supply(const token_id : nat; const s : rwaTokenStorageType) : nat is
    case Big_map.find_opt(token_id, s.total_supply) of [
            Some (_v) -> _v
        |   None      -> 0n
    ]


(* get_balance
    - Given a ledger key (consisting of token_id = sp.TNat, owner = sp.TAddress) allows the 
      consumer to view the current balance.
*)
[@view] function get_balance(const ledger_key : ledgerKeyType; const s : rwaTokenStorageType) : nat is
    case Big_map.find_opt(ledger_key, s.ledger) of [
            Some (_v) -> _v
        |   None      -> 0n
    ]



(* owner_of
    - Given a token id (sp.TNat) allows the consumer to view the current owner of a given token id.
*)
[@view] function owner_of(const tokenId : nat; var s : rwaTokenStorageType) : option(address) is
    Big_map.find_opt(tokenId, s.ownerLedger)



(* next_token_id
    - Get the next token id
*)
[@view] function next_token_id(const _ : unit; var s : rwaTokenStorageType) : nat is
    s.nextTokenId



(* check if operator *)
[@view] function is_operator(const operator : (ownerType * operatorType * nat); const store : rwaTokenStorageType) : bool is
    Big_map.mem(operator, store.operators)



(* get: metadata *)
[@view] function token_metadata(const tokenId : nat; const store : rwaTokenStorageType) : option(tokenMetadataType) is
    case Big_map.find_opt(tokenId, store.token_metadata) of [
            Some (_metadata)  -> Some(_metadata)
        |   None              -> (None : option(tokenMetadataType))
    ]


(* getUserBalanceAtTimestamp
    - View the balance of a user at an approximate timestamp given the tokenId, userAddress, timestamp, and optional start/end counter
*)
[@view] function getUserBalanceAtTimestamp(const viewBalanceAtTimestamp : viewBalanceAtTimestampType; const s : rwaTokenStorageType) : nat is
block {

    const tokenId    : nat        = viewBalanceAtTimestamp.tokenId;
    const user       : address    = viewBalanceAtTimestamp.user;
    const timestamp  : timestamp  = viewBalanceAtTimestamp.timestamp;

    verifyTokenIsDefined(tokenId, s);

    var userChunkRecord : userChunkRecordType := case s.userChunkLedger[user] of [
            Some(_record) -> _record
        |   None          -> record [
                chunkCounter    = 1n;
                snapshotCounter = 0n;
            ]
    ];

    const userTokenCounter : nat = userChunkRecord.snapshotCounter;

    // set end counter (soft check: set end counter to last user token counter if given end counter param is greater than last user token counter)
    const endCounter  : nat     = case viewBalanceAtTimestamp.endCounter of [
            Some(_counter) -> if _counter > userTokenCounter then userTokenCounter else _counter
        |   None           -> userTokenCounter 
    ];

    // set start counter
    const startCounter  : nat     = case viewBalanceAtTimestamp.startCounter of [
            Some(_counter) -> if _counter < endCounter then _counter else failwith(error_INVALID_START_COUNTER)
        |   None           -> 1n
    ];

    // init loop variables
    var keepLoop            : bool  := True;
    var firstValueCheck     : bool  := False;
    var snapshotCounter     : nat   := startCounter;
    var chunkCounter        : nat   := startCounter/1000n + 1n;
    var previousBalance     : nat   := 0n;
    var balanceAtTimestamp  : nat   := 0n;

    while keepLoop = True block {
        
        const snapshotKey : (nat * address * nat) = (tokenId, user, chunkCounter);
        const snapshotMapChunk : snapshotMapChunkType = case s.snapshotLedger[snapshotKey] of [
                Some(_map) -> _map
            |   None       -> (map[] : snapshotMapChunkType)
        ];

        case snapshotMapChunk[snapshotCounter] of [
                Some(_snapshot) -> {

                    const timestampDiff : int = _snapshot.1 - timestamp;

                    if keepLoop and timestampDiff > 0 then {
                        // snapshot timestamp greater than given timestamp: stop loop 
                        keepLoop := False;
                    } else {
                        // snapshot timestamp less than given timestamp: continue loop and set previousBalance
                        previousBalance := _snapshot.0;
                        snapshotCounter := snapshotCounter + 1n;
                        chunkCounter := snapshotCounter/1000n + 1n;
                    };

                    // set balance at timestamp to the previous balance
                    balanceAtTimestamp := previousBalance;

                    // if given timestamp (for snapshot) is before the first snapshot (at snapshot counter 1), then user balance should be 0
                    if _snapshot.1 > timestamp and snapshotCounter = 1n then {
                        firstValueCheck := True;
                        keepLoop := False;
                        balanceAtTimestamp := 0n;
                    } else skip;

                    // prevent false positives: the first snapshot in loop should always take place before given timestamp
                    //      - if not, wrong balance will be given if given timestamp is greater than the first snapshot in loop
                    if firstValueCheck = False then {
                        if _snapshot.1 > timestamp then failwith(error_START_COUNTER_SNAPSHOT_TIMESTAMP_GREATER_THAN_BALANCE_TIMESTAMP) else skip;
                        firstValueCheck := True;
                    } else skip;

                }
            |   None -> keepLoop := False
        ]
    };

} with balanceAtTimestamp
    


(* getUserSnapshots
    - Get a user snapshots from start counter to end counter
*)
[@view] function getUserSnapshots(const viewUserSnapshots : viewUserSnapshotsType; const s : rwaTokenStorageType) : list(snapshotType) is
block {

    const tokenId    : nat        = viewUserSnapshots.tokenId;
    const user       : address    = viewUserSnapshots.user;

    verifyTokenIsDefined(tokenId, s);

    var userChunkRecord : userChunkRecordType := case s.userChunkLedger[user] of [
            Some(_record) -> _record
        |   None          -> record [
                chunkCounter    = 1n;
                snapshotCounter = 0n;
            ]
    ];

    const userTokenCounter : nat = userChunkRecord.snapshotCounter;

    // set end counter (soft check: set end counter to last user token counter if given end counter param is greater than last user token counter)
    const endCounter : nat = case viewUserSnapshots.endCounter of [
            Some(_counter) -> if _counter > userTokenCounter then userTokenCounter else _counter
        |   None           -> userTokenCounter 
    ];

    // set start counter
    const startCounter : nat = case viewUserSnapshots.startCounter of [
            Some(_counter) -> if _counter < endCounter then _counter else failwith(error_INVALID_START_COUNTER)
        |   None           -> 1n
    ];

    // init loop 
    var keepLoop            : bool               := True;
    var snapshotCounter     : nat                := startCounter;
    var chunkCounter        : nat                := startCounter/1000n + 1n;
    var userSnapshotList    : list(snapshotType) := list [];
    
    // inclusive of end counter snapshot
    while keepLoop = True block {

        if snapshotCounter = endCounter + 1n then {
            
            keepLoop := False;

        } else {

            const snapshotKey : (nat * address * nat) = (tokenId, user, chunkCounter);
            const snapshotMapChunk : snapshotMapChunkType = case s.snapshotLedger[snapshotKey] of [
                    Some(_map) -> _map
                |   None       -> (map[] : snapshotMapChunkType)
            ];

            userSnapshotList := case snapshotMapChunk[snapshotCounter] of [
                    Some(_snapshot) -> _snapshot # userSnapshotList
                |   None            -> {
                        keepLoop := False
                    } with userSnapshotList
            ];
            
            snapshotCounter := snapshotCounter + 1n;
            chunkCounter := snapshotCounter/1000n + 1n;

        };
        
    };

} with userSnapshotList

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
// SuperAdmin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setSuperAdmin entrypoint *)
function setSuperAdmin(const newAdminAddress : address; var s : rwaTokenStorageType) : return is
block {

    verifySenderIsSuperAdmin(s); // check that sender is super admin 
    s.newSuperAdmin := Some(newAdminAddress);
    
} with (noOperations, s)



(*  claimSuperAdmin entrypoint *)
function claimSuperAdmin(var s : rwaTokenStorageType) : return is
block {

    // get sender and new super admin address 
    const sender : address = Mavryk.get_sender();
    const newSuperAdmin : address = case s.newSuperAdmin of [
            Some(_address) -> _address
        |   None           -> failwith(error_NO_NEW_SUPER_ADMIN_FOUND)
    ];

    // check if sender is not new super admin 
    if sender =/= newSuperAdmin then failwith(error_SENDER_IS_NOT_NEW_SUPER_ADMIN) else skip;
    
    // set new super admin
    s.superAdmin    := newSuperAdmin;
    s.newSuperAdmin := None;
    
} with (noOperations, s)



(* setTokenKyc entrypoint 
    - Allows to specify the kyc contract for the token
*)
function setTokenKyc(const kycAddress : address; var s : rwaTokenStorageType) : return is
block{

    // verify sender is super admin
    verifySenderIsSuperAdmin(s);
    s.kycAddress := kycAddress;

} with (noOperations, s)



(* kill entrypoint 
    - Wipes irreversibly the storage and ultimately kills the contract such that it can no longer be used. All tokens on it will be affected. Only special admin of token id 0 can do this.
*)
function kill(var s : rwaTokenStorageType) : return is
block{

    // verify is super admin
    verifySenderIsSuperAdmin(s);

    s.isPaused          := True;
    s.ledger            := (big_map[] : ledgerType);
    s.token_metadata    := (big_map[] : tokenMetadataLedgerType);
    s.total_supply      := (big_map[] : totalSupplyType);
    s.operators         := (big_map[] : operatorsType);

} with (noOperations, s)

// ------------------------------------------------------------------------------
// SuperAdmin Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Admin Entrypoints Begin
// ------------------------------------------------------------------------------

(*  setTokenMetadata entrypoint *)
function setTokenMetadata(const token_metadata_list : list(tokenMetadataType); var s : rwaTokenStorageType) : return is
block {

    for token_metadata in list token_metadata_list block {

        // verify is admin
        verifySenderIsAdmin(s);

        s.token_metadata[token_metadata.token_id] := token_metadata;

    }

} with (noOperations, s)



(* mint entrypoint 
   - Allows minting of new tokens to the defined recipient address, only RWA token admins can do this
*)
function mint(const mintList : list(mintType); var s : rwaTokenStorageType) : return is
block {

    for mintParams in list mintList block {

        const tokenId       : nat       = s.nextTokenId;
        const amount        : nat       = 1n;
        const userAddress   : address   = mintParams.address;
        const token_metadata : bytes    = mintParams.token_metadata;

        // verify is admin
        verifySenderIsAdmin(s);

        const recipient_ledger_key : ledgerKeyType = record [
            owner       = userAddress;
            token_id    = tokenId;
        ];

        s.token_metadata[tokenId] := record [
            token_id   = tokenId;
            token_info = map["" -> token_metadata];
        ];

        const newUserTokenBalance : nat = amount;

        var userChunkRecord : userChunkRecordType := case s.userChunkLedger[userAddress] of [
                Some(_record) -> _record
            |   None          -> record [
                    chunkCounter    = 1n;
                    snapshotCounter = 0n;
                ]
        ];

        const userTokenChunk : nat          = userChunkRecord.chunkCounter;
        const userSnapshotCounter : nat     = userChunkRecord.snapshotCounter + 1n;

        // take user balance snapshot
        s := takeUserBalanceSnapshot(tokenId, userAddress, userTokenChunk, userSnapshotCounter, newUserTokenBalance, s);

        // update storage
        s.ledger[recipient_ledger_key]      := newUserTokenBalance;
        s.ownerLedger[tokenId]              := userAddress;

        userChunkRecord.chunkCounter        := userSnapshotCounter/1000n + 1n;
        userChunkRecord.snapshotCounter     := userSnapshotCounter;
        s.userChunkLedger[userAddress]      := userChunkRecord;

        s.nextTokenId := s.nextTokenId + 1n;
        s.total_supply[tokenId] := case s.total_supply[tokenId] of [
                Some (_v) -> _v + amount
            |   None      -> amount
        ];

    }

} with (noOperations, s)



(* burn entrypoint 
    - Allows burning tokens on the defined recipient address, only RWA token admins can do this
*)
function burn(const burnList : list(burnType); var s : rwaTokenStorageType) : return is
block {

    for burnParams in list burnList block {

        const tokenId       : nat     = burnParams.token_id;
        const amount        : nat     = 1n;
        const userAddress   : address = burnParams.address;

        // verify is admin
        verifySenderIsAdmin(s);

        const recipient_ledger_key : ledgerKeyType = record [
            owner       = userAddress;
            token_id    = tokenId;
        ];

        verifySufficientBalance(recipient_ledger_key, amount, s);

        const userTokenBalance : nat = case s.ledger[recipient_ledger_key] of [
                Some(_v) -> _v
            |   None     -> 0n
        ];

        const newUserTokenBalance : nat = if userTokenBalance > amount then abs(userTokenBalance - amount) else 0n;

        var userChunkRecord : userChunkRecordType := case s.userChunkLedger[userAddress] of [
                Some(_record) -> _record
            |   None          -> record [
                    chunkCounter    = 1n;
                    snapshotCounter = 0n;
                ]
        ];

        const userTokenChunk : nat          = userChunkRecord.chunkCounter;
        const userSnapshotCounter : nat     = userChunkRecord.snapshotCounter + 1n;

        // take user balance snaphsot
        s := takeUserBalanceSnapshot(tokenId, userAddress, userTokenChunk, userSnapshotCounter, newUserTokenBalance, s);

        s.ledger[recipient_ledger_key]      := newUserTokenBalance;
        s.ownerLedger[tokenId]              := burnAddress;

        userChunkRecord.chunkCounter        := userSnapshotCounter/1000n + 1n;
        userChunkRecord.snapshotCounter     := userSnapshotCounter;
        s.userChunkLedger[userAddress]      := userChunkRecord;

        s.total_supply[tokenId] := case s.total_supply[tokenId] of [
                Some (_v) -> if _v > amount then abs(_v - amount) else 0n
            |   None      -> 0n
        ];

        if newUserTokenBalance = 0n then remove recipient_ledger_key from map s.ledger else skip;

    }

} with (noOperations, s)



(* pause entrypoint 
    - Allows pausing of tokens, only RWA token admins can do this
*)
function pause(var s : rwaTokenStorageType) : return is
block{

    // verify is admin
    verifySenderIsAdmin(s);
    s.isPaused := True

} with (noOperations, s)



(* unpause entrypoint 
    - Allows unpausing of tokens, only RWA token admins can do this
*)
function unpause(var s : rwaTokenStorageType) : return is
block{

    // verify is admin
    verifySenderIsAdmin(s);
    s.isPaused := False;

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Owner Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Open Entrypoints Begin
// ------------------------------------------------------------------------------

(* transfer entrypoint *)
function transfer(const transfers : fa2TransferType; var s : rwaTokenStorageType) : return is
block{

    function makeTransfer(const account : return; const transfer : transferType) : return is
        block {

            const owner : ownerType  = transfer.from_;
            const txs : list(txType) = transfer.txs;
            
            function transferTokens(var accumulator : rwaTokenStorageType; const tx : txType) : rwaTokenStorageType is
            block {

                const tokenId       : tokenIdType       = tx.token_id;
                const amount        : tokenBalanceType  = tx.amount;
                const receiver      : ownerType         = tx.to_;

                const from_user : ledgerKeyType = record [
                    owner       = owner;
                    token_id    = tokenId;
                ];

                const to_user : ledgerKeyType = record [
                    owner       = receiver;
                    token_id    = tokenId;
                ];

                const validationTransfer : validationTransferType = record [
                    from_       = owner;
                    to_         = receiver;
                    token_id    = tokenId;
                    amount      = amount;
                ];

                const isTransferValidView : option (bool) = Mavryk.call_view("view_is_transfer_valid", validationTransfer, accumulator.kycAddress);
                const _isTransferValid : bool = case isTransferValidView of [
                        Some (_bool) -> if _bool = False then failwith("error_CANNOT_TRANSFER") else True
                    |   None         -> failwith("error_VIEW_IS_TRANSFER_VALID_NOT_FOUND")
                ];

                verifySenderIsOwnerOrOperator(owner, tokenId, account.1.operators);

                verifyTokenIsDefined(tokenId, accumulator);

                verifyTokenIsNotPaused(accumulator);
                    
                verifySufficientBalance(from_user, amount, accumulator);

                const fromUserTokenBalance : nat = case accumulator.ledger[from_user] of [
                        Some(_v) -> _v
                    |   None     -> 0n
                ];

                var fromUserChunkRecord : userChunkRecordType := case accumulator.userChunkLedger[owner] of [
                        Some(_record) -> _record
                    |   None          -> record [
                            chunkCounter    = 1n;
                            snapshotCounter = 0n;
                        ]
                ];

                const fromUserTokenChunk : nat       = fromUserChunkRecord.chunkCounter;
                const fromUserSnapshotCounter : nat  = fromUserChunkRecord.snapshotCounter + 1n;

                const toUserTokenBalance : nat = case accumulator.ledger[to_user] of [
                        Some(_v) -> _v
                    |   None     -> 0n
                ];

                var toUserChunkRecord : userChunkRecordType := case accumulator.userChunkLedger[receiver] of [
                        Some(_record) -> _record
                    |   None          -> record [
                            chunkCounter    = 1n;
                            snapshotCounter = 0n;
                        ]
                ];

                const toUserTokenChunk : nat        = toUserChunkRecord.chunkCounter;
                const toUserSnapshotCounter : nat   = toUserChunkRecord.snapshotCounter + 1n;

                const newFromUserTokenBalance : nat = abs(fromUserTokenBalance - amount);
                const newToUserTokenBalance : nat   = toUserTokenBalance + amount;

                if amount > 0n then {

                    accumulator := takeUserBalanceSnapshot(tokenId, owner, fromUserTokenChunk, fromUserSnapshotCounter, newFromUserTokenBalance, accumulator);
                    accumulator := takeUserBalanceSnapshot(tokenId, receiver, toUserTokenChunk, toUserSnapshotCounter, newToUserTokenBalance, accumulator);

                    // update storage
                    accumulator.ledger[from_user]           := newFromUserTokenBalance;
                    accumulator.ledger[to_user]             := newToUserTokenBalance;

                    accumulator.ownerLedger[tokenId]        := receiver;

                    fromUserChunkRecord.chunkCounter        := fromUserSnapshotCounter/1000n + 1n;
                    fromUserChunkRecord.snapshotCounter     := fromUserSnapshotCounter;
                    accumulator.userChunkLedger[owner]      := fromUserChunkRecord;

                    toUserChunkRecord.chunkCounter          := toUserSnapshotCounter/1000n + 1n;
                    toUserChunkRecord.snapshotCounter       := toUserSnapshotCounter;
                    accumulator.userChunkLedger[receiver]   := toUserChunkRecord;
                    
                } else skip;

            } with accumulator;

            const updatedOperations : list(operation) = (nil: list(operation));
            const updatedStorage : rwaTokenStorageType = List.fold(transferTokens, txs, account.1);

        } with (mergeOperations(updatedOperations,account.0), updatedStorage)

} with List.fold(makeTransfer, transfers, ((nil: list(operation)), s))

// ------------------------------------------------------------------------------
// Open Entrypoints End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// FA2 Entrypoints Begin
// ------------------------------------------------------------------------------

(* balance_of entrypoint *)
function balance_of(const balance_of_requests : balanceOfType; const s : rwaTokenStorageType) : return is
block{

    function retrieveBalance(const request : balanceOfRequestType) : balanceOfResponse is
        block{

            const ledger_key : ledgerKeyType = record [
                token_id    = request.token_id;
                owner       = request.owner;
            ];

            verifyTokenIsDefined(request.token_id, s);

            const token_balance : tokenBalanceType = case Big_map.find_opt(ledger_key, s.ledger) of [
                    Some (_v) -> _v
                |   None      -> 0n
            ];

            const response : balanceOfResponse = record[
                request = request;
                balance = token_balance
            ];

        } with (response);

      const requests   : list(balanceOfRequestType) = balance_of_requests.requests;
      const callback   : contract(list(balanceOfResponse)) = balance_of_requests.callback;
      const responses  : list(balanceOfResponse) = List.map(retrieveBalance, requests);
      const operation  : operation = Mavryk.transaction(responses, 0mav, callback);

} with (list[operation],s)



(* update_operators entrypoint
    - As per FA2 standard, allows a token owner to set an operator who will be allowed to perform transfers on her/his behalf
 *)
function update_operators(const updateOperatorsParams : updateOperatorsType; const s : rwaTokenStorageType) : return is
block{

    var updatedOperators : operatorsType := List.fold(
        function(const operators : operatorsType; const updateOperator : updateOperatorVariantType) : operatorsType is
            case updateOperator of [
                    Add_operator (param)    -> addOperator(param, operators, s)
                |   Remove_operator (param) -> removeOperator(param, operators, s)
            ]
        ,
        updateOperatorsParams,
        s.operators
    )

} with (noOperations, s with record[operators = updatedOperators])

// ------------------------------------------------------------------------------
// FA2 Entrypoints End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Entrypoints End
//
// ------------------------------------------------------------------------------

(* main entrypoint *)
function main (const action : action; const s : rwaTokenStorageType) : return is

    case action of [

            // SuperAdmin Entrypoints
        |   SetSuperAdmin(params)               -> setSuperAdmin(params, s)            
        |   ClaimSuperAdmin(_params)            -> claimSuperAdmin(s)
        |   SetTokenKyc (params)                -> setTokenKyc(params, s)
        |   Kill (_params)                      -> kill(s)

            // Admin Entrypoints
        |   SetTokenMetadata (params)           -> setTokenMetadata(params, s)
        |   Mint (params)                       -> mint(params, s)
        |   Burn (params)                       -> burn(params, s)
        |   Pause (_params)                     -> pause(s)
        |   Unpause (_params)                   -> unpause(s)

            // FA2 Entrypoints
        |   Transfer (params)                   -> transfer(params, s)
        |   Update_operators (params)           -> update_operators(params, s)
        |   Balance_of (params)                 -> balance_of(params, s)
    ]

