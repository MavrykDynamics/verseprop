// ------------------------------------------------------------------------------
//
// Views Begin
//
// ------------------------------------------------------------------------------



(**
* @dev Function to retrieve a debt's details by its ID.
* @param _id The ID of the debt to retrieve.
* @return Debt Struct containing the debt details.
*)
[@view] function getDebt(const debtId : nat; const s : debtControllerStorageType) : option(debtRecordType) is
    Big_map.find_opt(debtId, s.debtLedger)



(**
* @dev Calculates the interest for a debt.
* @param _debtId The ID of the debt.
* @param _amount The amount to calculate the interest on
* @return The calculated interest.
*)
[@view] function calculateInterest(const calculateInterestParams : (nat * nat); const s : debtControllerStorageType) : option(nat) is
block {

    const _debtId : nat = calculateInterestParams.0;
    const _amount : nat = calculateInterestParams.1;

    var debtRecord : debtRecordType := case s.debtLedger[_debtId] of [
            Some(_record) -> _record
        |   None -> failwith("Debt with the provided id does not exist")
    ];

    var timePassed : nat := 0n;

    // Check if the debt is settled
    if debtRecord.settledDate = 0 then {
        // If not settled, use current time to calculate time passed
        timePassed = abs(Tezos.get_level() - debtRecord.startDate);
    } else {
        // If settled, use settledDate to calculate time passed
        timePassed = abs(debtRecord.settledDate - debtRecord.startDate);
    };

    const dailyInterest : nat   = debtRecord.interestRate / 10000n;
    const oneDayInSeconds : nat = 86400n;
    const interestAccrued : nat = (_amount * dailyInterest * timePassed) / oneDayInSeconds;

} with interestAccrued




(* View: get a lambda *)
[@view] function getLambdaOpt(const lambdaName: string; const s : debtControllerStorageType) : option(bytes) is
    Big_map.find_opt(lambdaName, s.lambdaLedger)

// ------------------------------------------------------------------------------
//
// Views End
//
// ------------------------------------------------------------------------------