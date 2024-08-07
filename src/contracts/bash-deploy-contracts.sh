#!/bin/bash

CONTRACTS_DEPLOY_ARRAY=()
COMMANDS=()
DEPLOYMENT_FILE=./test/contractDeployments.json

# Parse arguments
# if [ $# -eq 0 ]
# then
#     help
# fi
while [ $# -gt 0 ] ; do
  case $1 in
    -h | --help)
        help
    ;;
    -c | --contracts)
        CONTRACTS=$2
        IFS=',' read -r -a CONTRACTS_DEPLOY_ARRAY <<< "$CONTRACTS"
    ;;
  esac
  shift
done

if [ ${#CONTRACTS_DEPLOY_ARRAY[@]} -eq 0 ]
then
    echo "Error: You must specify at least one contract to deploy."
    echo "Use -h or --help to display usage."
    exit 1
fi

if [ ! -f $DEPLOYMENT_FILE ]
then
    echo '{}' > $DEPLOYMENT_FILE
fi

for contract_test in "${CONTRACTS_DEPLOY_ARRAY[@]}"; do
    case "$contract_test" in
        
        mockTokens)
            echo "Deploying Mock Tokens"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/00_deploy_mock_tokens.spec.ts --bail --timeout 9000000 --exit ")
            ;;
        superAdmin)
            echo "Deploying SuperAdmin"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/01_deploy_super_admin.spec.ts --bail --timeout 9000000 --exit ")
            ;;
        kyc)
            echo "Deploying KYC Contract"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/02_deploy_kyc.spec.ts --bail --timeout 9000000 --exit ")
            ;;
        rwaToken)
            echo "Deploying RWA Token"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/03_deploy_rwa_token_non_fungible.spec.ts --bail --timeout 9000000 --exit ")
            ;;
        debtController)
            echo "Deploying Debt Controller"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/04_deploy_debt_controller.spec.ts --bail --timeout 9000000 --exit ")
            ;;
        all)
            echo "Deploy all contracts"
            COMMANDS+=("yarn ts-mocha --paths test/deploy/00_deploy_mock_tokens.spec.ts --bail --timeout 9000000 --exit ")
            COMMANDS+=("yarn ts-mocha --paths test/deploy/01_deploy_super_admin.spec.ts --bail --timeout 9000000 --exit ")
            COMMANDS+=("yarn ts-mocha --paths test/deploy/02_deploy_kyc.spec.ts --bail --timeout 9000000 --exit ")
            COMMANDS+=("yarn ts-mocha --paths test/deploy/03_deploy_rwa_token_non_fungible.spec.ts --bail --timeout 9000000 --exit ")
            COMMANDS+=("yarn ts-mocha --paths test/deploy/04_deploy_debt_controller.spec.ts --bail --timeout 9000000 --exit ")
            ;;
        *)
            echo "Unknown contract test: $contract_test"
            ;;
    esac
done

for cmd in "${COMMANDS[@]}"; do
    echo "Executing command: $cmd"
    eval $cmd
done