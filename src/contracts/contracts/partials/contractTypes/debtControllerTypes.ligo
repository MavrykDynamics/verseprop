// ------------------------------------------------------------------------------
// Storage Types
// ------------------------------------------------------------------------------

type currencyType is 
    |   MAV         of unit 
    |   USDC        of unit

type debtStatusType is
    |   OPEN        of unit
    |   FUNDED      of unit
    |   SETTLED     of unit
    |   UNFUNDED    of unit

type debtRecordType is [@layout:comb] record [
    maxAmount            : nat;
    interestRate         : nat;
    term                 : nat;
    walletAddress        : address;
    minInvestmentAmount  : nat;
    totalInvestment      : nat;
    status               : debtStatusType;
    startDate            : nat;
    settledDate          : nat;
    nftContractAddress   : address;
    tokenURI             : bytes;
    currency             : currencyType;
]

type debtLedgerType is big_map(nat, debtRecordType)

type tokenToInvestmentMapType is map(nat, nat)
type investmentLedgerType is big_map(nat, tokenToInvestmentMapType) // Mapping of debt ID to another mapping of token ID to investment amount.

// ------------------------------------------------------------------------------
// Action Types
// ------------------------------------------------------------------------------

type addDebtActionType is debtRecordType

type updateDebtActionType is (nat * debtRecordType)

type setInvestmentActionType is [@layout:comb] record [
    debtId   : nat;
    tokenId  : nat;
    amount   : nat;
]


type createDebtActionType is [@layout:comb] record [
    _amt                  : nat;
    _interestRate         : nat;
    _term                 : nat;
    _walletAddress        : address; 
    _minInvestmentAmount  : nat;
    _tokenURI             : bytes;
    _currency             : currencyType;
]

type addDepositActionType is [@layout:comb] record [
    _debtId               : nat;
    _amt                  : nat;
    _user                 : address;
]

type withdrawDepositActionType is [@layout:comb] record [
    _debtId               : nat;
    _tokenId              : nat;
    _user                 : address;
]

type payOffDebtActionType is [@layout:comb] record [
    _debtId               : nat;
    _user                 : address;
]

// ------------------------------------------------------------------------------
// Lambda Action Types
// ------------------------------------------------------------------------------

type debtControllerLambdaActionType is 

        // Admin Lambdas
        LambdaAddManager                  of (address)
    |   LambdaRemoveManager               of (address)
    |   LambdaAddAdmin                    of (address)
    |   LambdaRemoveAdmin                 of (address)
    |   LambdaUpdateMetadata              of updateMetadataType

        // Admin Debt Controller Lambdas
    |   LambdaAddDebt                     of addDebtActionType
    |   LambdaUpdateDebt                  of updateDebtActionType
    |   LambdaSetInvestment               of setInvestmentActionType
    |   LambdaSetFeeWallet                of (address)
        
        // Debt Controller Lambdas
    |   LambdaCreateDebt                  of createDebtActionType
    |   LambdaDisburseLoan                of (nat)
    |   LambdaReturnDeposit               of (nat)
    |   LambdaAddDeposit                  of addDepositActionType
    |   LambdaWithdrawDeposit             of withdrawDepositActionType
    |   LambdaPayOffDebt                  of payOffDebtActionType

// ------------------------------------------------------------------------------
// Storage
// ------------------------------------------------------------------------------

type debtControllerStorageType is [@layout:comb] record [
    
    admins                    : set(address);
    managers                  : set(address);

    superAdmin                : address;
    newSuperAdmin             : option(address);
    kycAddress                : address;
    
    feeWallet                 : address;        // Wallet address for collecting fees.
    usdcTokenAddress          : address;        // Address of the USDC token used for investments.

    metadata                  : metadataType;

    debtCounter               : nat;
    debtLedger                : debtLedgerType;
    investmentLedger          : investmentLedgerType;

    lambdaLedger              : lambdaLedgerType;
]

