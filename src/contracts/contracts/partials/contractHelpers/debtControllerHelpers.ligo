// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Entrypoint Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to get mint entrypoint
function getMintEntrypoint(const tokenAddress : address) : contract(list(mintType)) is
    case (Tezos.get_entrypoint_opt(
        "%mint",
        tokenAddress) : option(contract(list(mintType)))) of [
                Some(contr) -> contr
            |   None -> (failwith(error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(list(mintType)))
        ];


// helper function to get burn entrypoint
function getBurnEntrypoint(const tokenAddress : address) : contract(list(nat)) is
    case (Tezos.get_entrypoint_opt(
        "%burn",
        tokenAddress) : option(contract(list(nat)))) of [
                Some(contr) -> contr
            |   None -> (failwith(error_BURN_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(list(nat)))
        ];

// ------------------------------------------------------------------------------
// Entrypoint Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Helper Functions Begin
// ------------------------------------------------------------------------------

function getBalanceOf(const user : address; const tokenContractAddress : address) : nat is 
block {

    const getBalanceView : option(nat) = Tezos.call_view("get_balance", (user, 0n), tokenContractAddress);
    const balance : nat = case getBalanceView of [
            Some(_nat) -> _nat
        |   None       -> 0n
    ];

} with balance



function ownerOf(const tokenId : nat; const tokenContractAddress : address) : address is 
block {

    const ownerOfView : option(address) = Tezos.call_view("owner_of", tokenId, tokenContractAddress);
    const owner : address = case ownerOfView of [
            Some(_address) -> _address
        |   None           -> failwith("Owner not found.")
    ];

} with owner



function getNextTokenId(const tokenContractAddress : address) : int is 
block {

    const nextTokenView : option(nat) = Tezos.call_view("total_supply", unit, tokenContractAddress);
    const nextTokenIdNat : nat = case nextTokenView of [
            Some(_nat) -> _nat
        |   None       -> 0n
    ];
    const nextTokenId : int = int(nextTokenIdNat);

} with nextTokenId



function getTotalSupply(const tokenIdInt : int; const tokenContractAddress : address) : nat is 
block {

    const tokenId : nat = abs(tokenIdInt);
    const getTotalSupplyView : option(nat) = Tezos.call_view("view_total_supply", tokenId, tokenContractAddress);
    const totalSupply : nat = case getTotalSupplyView of [
            Some(_nat) -> _nat
        |   None       -> 0n
    ];

} with totalSupply



function _mintDebtNFTOperation(const user : address; const tokenURI : bytes; const tokenContractAddress : address) : operation is
block {

    const mintParams : mintType = record [
        token_metadata  = tokenURI;
        address         = user;
    ];

    const mintOperation : operation = Tezos.transaction(
        list[mintParams],
        0tez,
        getMintEntrypoint(tokenContractAddress)
    );

} with mintOperation



function _burnDebtNFTOperation(const tokenId : nat; const tokenContractAddress : address) : operation is
block {

    const burnOperation : operation = Tezos.transaction(
        list[tokenId],
        0tez,
        getBurnEntrypoint(tokenContractAddress)
    );

} with burnOperation



function _setInvestment(const debtId : nat; const tokenId : nat; const amount : nat; var s : debtControllerStorageType) : debtControllerStorageType is
block {

    var investmentMap : tokenToInvestmentMapType := case s.investmentLedger[debtId] of [
            Some(_map) -> {
                var tempInvestmentMap := _map;
                const investmentAmount : nat = case tempInvestmentMap[tokenId] of [
                        Some(_) -> failwith("TokenId under provided debtId already exists")
                    |   None    -> amount
                ]; 
                tempInvestmentMap[tokenId] := investmentAmount;
            } with tempInvestmentMap
        |   None       -> map[tokenId -> amount]
    ];

    s.investmentLedger[debtId] := investmentMap;

} with s

// ------------------------------------------------------------------------------
// Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// RWA Token Origination Helpers Begin
// ------------------------------------------------------------------------------

// helper funtion to prepare new RWA Token storage
function prepareRwaTokenStorage(const s : debtControllerStorageType) : rwaTokenStorageType is 
block {

    // Prepare storage
    const originatedRwaTokenStorageType : rwaTokenStorageType = record [

        superAdmin                  = s.superAdmin;
        newSuperAdmin               = (None : option(address));

        kycAddress                  = s.kycAddress;
        isPaused                    = True;

        metadata                    = big_map [];
        token_metadata              = big_map [];
        total_supply                = 0n;

        userChunkLedger             = big_map [];
        snapshotLedger              = big_map [];

        ledger                      = big_map [];
        ownerLedger                 = big_map [];
        operators                   = big_map [];
    ];

} with originatedRwaTokenStorageType 

// ------------------------------------------------------------------------------
// RWA Token Origination Helpers End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Lambda Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to unpack and execute entrypoint logic stored as bytes in lambdaLedger
function unpackLambda(const lambdaBytes : bytes; const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is 
block {

    const res : return = case (Bytes.unpack(lambdaBytes) : option(debtControllerUnpackLambdaFunctionType)) of [
            Some(f) -> f(debtControllerLambdaAction, s)
        |   None    -> failwith(error_UNABLE_TO_UNPACK_LAMBDA)
    ];

} with (res.0, res.1)

// ------------------------------------------------------------------------------
// Lambda Helper Functions End
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
//
// Helper Functions End
//
// ------------------------------------------------------------------------------
