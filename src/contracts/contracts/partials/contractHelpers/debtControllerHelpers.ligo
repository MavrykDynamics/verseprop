// ------------------------------------------------------------------------------
//
// Helper Functions Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Entrypoint Helper Functions Begin
// ------------------------------------------------------------------------------

// helper function to get mint entrypoint
function getMintEntrypoint(const tokenAddress : address) : contract(list(mintOrBurnType)) is
    case (Tezos.get_entrypoint_opt(
        "%mint",
        tokenAddress) : option(contract(list(mintOrBurnType)))) of [
                Some(contr) -> contr
            |   None -> (failwith(error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(list(mintOrBurnType)))
        ];


// helper function to get burn entrypoint
function getBurnEntrypoint(const tokenAddress : address) : contract(list(mintOrBurnType)) is
    case (Tezos.get_entrypoint_opt(
        "%burn",
        tokenAddress) : option(contract(list(mintOrBurnType)))) of [
                Some(contr) -> contr
            |   None -> (failwith(error_BURN_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND) : contract(list(mintOrBurnType)))
        ];

// ------------------------------------------------------------------------------
// Entrypoint Helper Functions End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Helper Functions Begin
// ------------------------------------------------------------------------------

function getBalanceOf(const user : address; const tokenContractAddress : address) : nat is 
block {

    const getBalanceView : option(nat) = Tezos.call_view("get_balance", [user, 0n], tokenContractAddress);
    const balance : nat = case getBalanceView of [
            Some(_nat) -> _nat
        |   None       -> 0n
    ];

} with balance



function ownerOf(const tokenId : nat; const tokenContractAddress : address) : address is 
block {

    const ownerOfView : option(nat) = Tezos.call_view("owner_of", tokenId, tokenContractAddress);
    const owner : address = case ownerOfView of [
            Some(_address) -> _address
        |   None           -> failwith("Owner not found.")
    ];

} with owner



function getNextTokenId(const tokenContractAddress : address) : nat is 
block {

    const nextTokenView : option(nat) = Tezos.call_view("next_token_id", unit, tokenContractAddress);
    const nextTokenId : nat = case nextTokenView of [
            Some(_nat) -> _nat
        |   None       -> 0n
    ];

} with nextTokenId



function getTotalSupply(const tokenId : nat; const tokenContractAddress : address) : nat is 
block {

    const getTotalSupplyView : option(nat) = Tezos.call_view("view_total_supply", tokenId, tokenContractAddress);
    const totalSupply : nat = case getTotalSupplyView of [
            Some(_nat) -> _nat
        |   None       -> 0n
    ];

} with totalSupply



function _mintDebtNFTOperation(const user : address; const tokenId : nat; const amount : nat; const tokenContractAddress : address) : operation is
block {

    const mintParams : mintOrBurnType = record [
        token_id  = tokenId;
        amount    = amount;
        address   = user;
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
                const investmentAmount : nat = case _map[tokenId] of [
                        Some(_) -> failwith("TokenId under provided debtId already exists")
                    |   None    -> amount
                ]; 
                _map[tokenId] := investmentAmount;
            } with _map
        |   None       -> map[tokenId -> amount]
    ];

    s.investmentLedger[debtId] := investmentMap;

} with s

// ------------------------------------------------------------------------------
// Helper Functions End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Helper Functions End
//
// ------------------------------------------------------------------------------
