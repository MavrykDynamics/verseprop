// ------------------------------------------------------------------------------
//
// Debt Controller Lambdas Begin
//
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Admin Lambdas Begin
// ------------------------------------------------------------------------------

(**
* @dev Public function to grant the manager role to a specified address. Can only be called by an admin.
* @param manager Address to be granted the manager role.
*)
function lambdaAddManager(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {
    
    case debtControllerLambdaAction of [
        |   LambdaAddManager(manager) -> {

                onlyAdmin(s.admins);

                s.managers := Set.add(manager, s.managers);

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(**
* @dev Public function to revoke the manager role from a specified address. Can only be called by an admin.
* @param manager Address from which the manager role will be revoked.
*)
function lambdaRemoveManager(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {
    
    case debtControllerLambdaAction of [
        |   LambdaRemoveManager(manager) -> {

                onlyAdmin(s.admins);

                s.managers := Set.remove(manager, s.managers);
                

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(**
* @dev Public function to grant the admin role to a new address. Can only be called by an existing admin.
* @param newAdmin Address to be granted the admin role.
*)
function lambdaAddAdmin(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {
    
    case debtControllerLambdaAction of [
        |   LambdaAddAdmin(newAdmin) -> {

                onlyAdmin(s.admins);

                s.admins := Set.add(newAdmin, s.admins);

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(**
* @dev Public function to revoke the admin role from a specified address. Can only be called by an existing admin.
* @param adminToRemove Address from which the admin role will be revoked.
*)
function lambdaRemoveAdmin(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    case debtControllerLambdaAction of [
        |   LambdaRemoveAdmin(adminToRemove) -> {

                onlyAdmin(s.admins);

                s.admins := Set.remove(adminToRemove, s.admins);

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(*  updateMetadata lambda - update the metadata at a given key *)
function lambdaUpdateMetadata(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    case debtControllerLambdaAction of [
        |   LambdaUpdateMetadata(updateMetadataParams) -> {

                onlyAdmin(s.admins);
                
                const metadataKey   : string = updateMetadataParams.metadataKey;
                const metadataHash  : bytes  = updateMetadataParams.metadataHash;
                
                s.metadata[metadataKey] := metadataHash;
            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Admin Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Admin Debt Controller Lambdas Begin
// ------------------------------------------------------------------------------

(**
* @dev Function to add a new debt. Can only be called by a manager.
* @param _debt Struct containing the debt details.
*)
function lambdaAddDebt(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    case debtControllerLambdaAction of [
        |   LambdaAddDebt(addDebtParams) -> {

                onlyManager(s.managers);

                const currentDebtCounter : nat = s.debtCounter;

                const debt : debtRecordType = record [
                    maxAmount            = addDebtParams.maxAmount;
                    interestRate         = addDebtParams.interestRate;
                    term                 = addDebtParams.term;
                    walletAddress        = addDebtParams.walletAddress;
                    minInvestmentAmount  = addDebtParams.minInvestmentAmount;
                    totalInvestment      = addDebtParams.totalInvestment;
                    status               = addDebtParams.status;
                    startDate            = addDebtParams.startDate;
                    settledDate          = addDebtParams.settledDate;
                    nftContractAddress   = addDebtParams.nftContractAddress;
                    tokenURI             = addDebtParams.tokenURI;
                    currency             = addDebtParams.currency;
                ];

                s.debtLedger[currentDebtCounter] := debt;

                // update debt counter
                s.debtCounter := currentDebtCounter + 1n;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(**
* @dev Function to update an existing debt. Can only be called by a manager.
* @param _id The ID of the debt to update.
* @param _debt Struct containing the new debt details.
*)
function lambdaUpdateDebt(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    case debtControllerLambdaAction of [
        |   LambdaUpdateDebt(updateDebtParams) -> {

                onlyManager(s.managers);

                const debtId : nat                 = updateDebtParams.0;
                const updatedDebt : debtRecordType = updateDebtParams.1;

                var debt : debtRecordType := case s.debtLedger[debtId] of [
                        Some(_record) -> _record
                    |   None -> failwith("Debt with the provided id does not exist")
                ];

                if debt.maxAmount >= 0n then skip else failwith("Debt with the provided id does not exist");

                s.debtLedger[debtId] := updatedDebt;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(**
* @dev Function to set investment for a debt. Can only be called by a manager.
* @param _debtId The ID of the debt.
* @param _tokenId The ID of the token being used for investment.
* @param _amount The amount of the investment.
*)
function lambdaSetInvestment(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    case debtControllerLambdaAction of [
        |   LambdaSetInvestment(setInvestmentParams) -> {

                onlyManager(s.managers);

                const debtId : nat  = setInvestmentParams.debtId;
                const tokenId : nat = setInvestmentParams.tokenId;
                const amount : nat  = setInvestmentParams.amount;

                s := _setInvestment(debtId, tokenId, amount, s);

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(**
* @dev Function to set the fee wallet address. Can only be called by an admin.
* @param _feeWallet The new fee wallet address.
*)
function lambdaSetFeeWallet(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    case debtControllerLambdaAction of [
        |   LambdaSetFeeWallet(_feeWallet) -> {
    
                onlyAdmin(s.admins);

                s.feeWallet := _feeWallet;

            }
        |   _ -> skip
    ];

} with (noOperations, s)

// ------------------------------------------------------------------------------
// Admin Debt Controller Lambdas End
// ------------------------------------------------------------------------------



// ------------------------------------------------------------------------------
// Debt Controller Lambdas Begin
// ------------------------------------------------------------------------------

(**
* @dev Creates a new debt.
* @param _amt The amount of the debt.
* @param _interestRate The interest rate of the debt.
* @param _term The term of the debt in months.
* @param _walletAddress The wallet address of the debtor to disburse to.
* @param _minInvestmentAmount The minimum investment amount required for deposit.
*)
function lambdaCreateDebt(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    case debtControllerLambdaAction of [
        |   LambdaCreateDebt(createDebtParams) -> {

                onlyAdmin(s.admins); // change from original where it is onlyOwner

                // todo: originate nft contract address
                const nftContract : address = Tezos.get_sender(); // temp

                const currentDebtCounter : nat = s.debtCounter;

                const debt : debtRecordType = record [
                    maxAmount            = createDebtParams._amt;
                    interestRate         = createDebtParams._interestRate;
                    term                 = createDebtParams._term;
                    walletAddress        = createDebtParams._walletAddress;
                    minInvestmentAmount  = createDebtParams._minInvestmentAmount;
                    totalInvestment      = 0n;
                    status               = OPEN;
                    startDate            = 0n;
                    settledDate          = 0n;
                    nftContractAddress   = nftContract;
                    tokenURI             = createDebtParams._tokenURI;
                    currency             = createDebtParams._currency;
                ];

                s.debtLedger[currentDebtCounter] := debt;

                // update debt counter
                s.debtCounter := currentDebtCounter + 1n;

            }
        |   _ -> skip
    ];

} with (noOperations, s)



(**
* @dev Disburses a loan once the investment goal has reached. Disables users from withdrawing from the pool.
* @param _debtId The ID of the debt.
*)
function lambdaDisburseLoan(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    var operations : list(operation) := nil;

    case debtControllerLambdaAction of [
        |   LambdaDisburseLoan(_debtId) -> {

                onlyAdmin(s.admins); // change from original where it is onlyOwner

                var debt : debtRecordType := case s.debtLedger[_debtId] of [
                        Some(_record) -> _record
                    |   None -> failwith("Debt with the provided id does not exist")
                ];

                if debt.status = OPEN then skip else failwith("Current loan status needs to be OPEN");
                if debt.totalInvestment = debt.maxAmount then skip else failwith("Investment goal not reached");

                // Transfer the Verseprop fee 2% to feeWallet and the rest to the debtor
                const versepropFee : nat = (debt.totalInvestment * 2n) / 100n;
                if debt.currency = MAV then {

                    // can omit this transfer operation as debt storage is equivalent to debt logic contract here
                    // operations := transferTez((Tezos.get_contract_with_error(Tezos.get_self_address(), "Error. Tez could not be sent to debt controller address.") : contract(unit)), versepropFee * 1mutez) # operations;

                    const loanAmount : nat = abs(debt.totalInvestment - versepropFee);
                    operations := transferTez((Tezos.get_contract_with_error(debt.walletAddress, "Error. Tez could not be sent to wallet address.") : contract(unit)), loanAmount * 1mutez) # operations;

                } else if debt.currency = USDC then {

                    // can omit this transfer operation as debt storage is equivalent to debt logic contract here
                    // operations := transferFa2Token(Tezos.get_self_address(), Tezos.get_self_address(), versepropFee, 0n, s.usdcTokenAddress) # operations;

                    const loanAmount : nat = abs(debt.totalInvestment - versepropFee);
                    operations := transferFa2Token(Tezos.get_self_address(), debt.walletAddress, loanAmount, 0n, s.usdcTokenAddress) # operations;

                };

                // Update status and startDate (to be used for interest calculation)
                debt.startDate         := Tezos.get_level();
                debt.status            := FUNDED;
                s.debtLedger[_debtId]  := debt;
                
            }
        |   _ -> skip
    ];

} with (operations, s)



(**
* @dev Returns deposits to investors if a loan is not disbursed.
* @param _debtId The ID of the debt.
*)
function lambdaReturnDeposit(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    var operations : list(operation) := nil;

    case debtControllerLambdaAction of [
        |   LambdaReturnDeposit(_debtId) -> {

                onlyAdmin(s.admins); // change from original where it is onlyOwner

                var debt : debtRecordType := case s.debtLedger[_debtId] of [
                        Some(_record) -> _record
                    |   None -> failwith("Debt with the provided id does not exist")
                ];

                if debt.status = OPEN then skip else failwith("Funds can only be returned if they have not been sent");

                const nftContract : address = debt.nftContractAddress;
                const nextTokenId : int = getNextTokenId(nftContract); 

                var loopCounter : int := 0;
                for i := loopCounter to nextTokenId block {

                    // Checks if the token hasn't been burned
                    const totalSupply : nat = getTotalSupply(i, nftContract);
                    if totalSupply > 0n then {

                        const investmentAmount : nat = case s.investmentLedger[_debtId] of [
                                Some(_map) -> {
                                    const _investmentAmount : nat = case _map[abs(i)] of [
                                            Some(_amt) -> _amt
                                        |   None       -> 0n
                                    ]; 
                                } with _investmentAmount
                            |   None       -> 0n
                        ];

                        if investmentAmount > 0n then {

                            const owner : address = ownerOf(abs(i), nftContract); 
                            
                            // Refund logic
                            if debt.currency = MAV then {
                                operations := transferTez((Tezos.get_contract_with_error(owner, "Error. Tez could not be sent to wallet address.") : contract(unit)), investmentAmount * 1mutez) # operations;
                            } else if debt.currency = USDC then {
                                operations := transferFa2Token(Tezos.get_self_address(), owner, investmentAmount, 0n, s.usdcTokenAddress) # operations;
                                operations := _burnDebtNFTOperation(abs(i), nftContract) # operations; // Burn the NFT
                            };
                        }

                    };

                };

                // Update debt status
                debt.status           := UNFUNDED;
                s.debtLedger[_debtId] := debt;

            }
        |   _ -> skip
    ];

} with (operations, s)



(**
* @dev Adds a deposit to a debt, which mints the NFT representing the investment.
* @param _debtId The ID of the debt.
*)
function lambdaAddDeposit(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    var operations : list(operation) := nil;

    case debtControllerLambdaAction of [
        |   LambdaAddDeposit(addDepositParams) -> {

                // todo: allow admin to specify the user instead of Tezos.get_sender()

                const _debtId : nat = addDepositParams._debtId;
                const _amt : nat    = addDepositParams._amt;

                var debt : debtRecordType := case s.debtLedger[_debtId] of [
                        Some(_record) -> _record
                    |   None -> failwith("Debt with the provided id does not exist")
                ];

                if debt.status = OPEN then skip else failwith("Loan is not accepting funds from deposits");
                if debt.totalInvestment + _amt <= debt.maxAmount then skip else failwith( "Investment limit exceeded");

                // Ensure user provided sufficient amount in specified debt currency

                if debt.currency = MAV then {

                    if (Tezos.get_amount() / 1mutez) = _amt then skip else failwith("Incorrect MAV amount");
                    if _amt >= debt.minInvestmentAmount then skip else failwith("Minimum investment amount not sufficient");

                    operations := transferTez((Tezos.get_contract_with_error(Tezos.get_self_address(), "Error. Tez could not be sent to address.") : contract(unit)), Tezos.get_amount()) # operations;

                } else if debt.currency = USDC then {

                    if _amt >= debt.minInvestmentAmount then skip else failwith("Minimum investment amount not sufficient");
                    operations := transferFa2Token(Tezos.get_self_address(), Tezos.get_sender(), _amt, 0n, s.usdcTokenAddress) # operations;

                };

                // Mint NFT which is associated with the investment amount
                const nftContract : address = debt.nftContractAddress;
                const tokenId : nat = abs(getNextTokenId(nftContract));
                operations := _mintDebtNFTOperation(Tezos.get_sender(), tokenId, 1n, nftContract) # operations;
                s := _setInvestment(_debtId, tokenId, _amt, s);

                // Update total investment amount on the debt
                debt.totalInvestment  := debt.totalInvestment + _amt;
                s.debtLedger[_debtId] := debt;

            }
        |   _ -> skip
    ];

} with (operations, s)



(**
* @dev Withdraws a deposit and interest for an investor.
* @param _debtId The ID of the debt.
* @param _tokenId The ID of the NFT token.
*)
function lambdaWithdrawDeposit(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    var operations : list(operation) := nil;

    case debtControllerLambdaAction of [
        |   LambdaWithdrawDeposit(withdrawDepositParams) -> {

                // todo: allow admin to specify the user instead of Tezos.get_sender()

                const _debtId : nat   = withdrawDepositParams._debtId;
                const _tokenId : nat  = withdrawDepositParams._tokenId;

                var debt : debtRecordType := case s.debtLedger[_debtId] of [
                        Some(_record) -> _record
                    |   None -> failwith("Debt with the provided id does not exist")
                ];

                if debt.status = OPEN or debt.status = SETTLED then skip else failwith("Invalid loan status");
                if debt.totalInvestment > 0n then skip else failwith("No funds left to settle");

                const nftContract : address = debt.nftContractAddress;
                if ownerOf(_tokenId, nftContract) = Tezos.get_sender() then skip else failwith("Caller is not the owner of the NFT");

                const investmentAmount : nat = case s.investmentLedger[_debtId] of [
                        Some(_map) -> {
                            const _investmentAmount : nat = case _map[_tokenId] of [
                                    Some(_amt) -> _amt
                                |   None       -> 0n
                            ]; 
                        } with _investmentAmount
                    |   None       -> 0n
                ];
                if investmentAmount > 0n then skip else failwith("No deposit found");

                // Calculate interest for the amount associated with the NFT
                const interest : nat = calculateInterest((_debtId, investmentAmount), s);
                const totalWithdrawal : nat = investmentAmount + interest;

                operations := _burnDebtNFTOperation(_tokenId, nftContract) # operations;

                if debt.currency = MAV then {
                    if (Tezos.get_balance() / 1mutez) >= totalWithdrawal then skip else failwith("Insufficient contract balance");
                    operations := transferTez((Tezos.get_contract_with_error(Tezos.get_sender(), "Error. Tez could not be sent to address.") : contract(unit)), totalWithdrawal * 1mutez) # operations;
                } else if debt.currency = USDC then {
                    const balanceOfContract : nat = getBalanceOf(Tezos.get_self_address(), s.usdcTokenAddress);
                    if balanceOfContract >= totalWithdrawal then skip else failwith("Insufficient contract balance");
                    operations := transferFa2Token(Tezos.get_self_address(), Tezos.get_sender(), totalWithdrawal, 0n, s.usdcTokenAddress) # operations;
                };

                debt.totalInvestment  := abs(debt.totalInvestment - investmentAmount);
                s.debtLedger[_debtId] := debt;

            }
        |   _ -> skip
    ];

} with (operations, s)



(**
* @dev Pays off a debt.
* @param _debtId The ID of the debt.
*)
function lambdaPayOffDebt(const debtControllerLambdaAction : debtControllerLambdaActionType; var s : debtControllerStorageType) : return is
block {

    var operations : list(operation) := nil;

    case debtControllerLambdaAction of [
        |   LambdaPayOffDebt(_debtId) -> {

                // todo: allow admin to specify the user instead of Tezos.get_sender()
                
                var debt : debtRecordType := case s.debtLedger[_debtId] of [
                        Some(_record) -> _record
                    |   None -> failwith("Debt with the provided id does not exist")
                ];

                if debt.status = FUNDED then skip else failwith("Loan not funded");

                const interest : nat = calculateInterest((_debtId, debt.maxAmount), s);
                const totalPayment : nat = debt.maxAmount + interest;

                if debt.currency = MAV then {
                    if (Tezos.get_amount() / 1mutez) >= totalPayment then skip else failwith("Insufficient payment");
                    operations := transferTez((Tezos.get_contract_with_error(Tezos.get_self_address(), "Error. Tez could not be sent to address.") : contract(unit)), Tezos.get_amount()) # operations;
                } else if debt.currency = USDC then {
                    operations := transferFa2Token(Tezos.get_sender(), Tezos.get_self_address(), totalPayment, 0n, s.usdcTokenAddress) # operations;
                };

                debt.status           := SETTLED;
                debt.settledDate      := Tezos.get_level();
                s.debtLedger[_debtId] := debt;

            }
        |   _ -> skip
    ];

} with (operations, s)

// ------------------------------------------------------------------------------
// Debt Controller Lambdas End
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
//
// Debt Controller Lambdas End
//
// ------------------------------------------------------------------------------