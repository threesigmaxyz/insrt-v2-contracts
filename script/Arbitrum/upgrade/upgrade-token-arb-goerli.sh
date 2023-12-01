#!/usr/bin/env bash
set -e

CHAIN_ID=421613
RPC_URL=$ARBITRUM_GOERLI_RPC_URL
UPGRADE_SCRIPT="01_upgradeTokenEOA.s.sol"
VERIFIER_URL="https://api-goerli.arbiscan.io/api"
export TOKEN_PROXY_ADDRESS="0x72cecbba2fd0c8c45204813896d6603cf4340cd8"

# Check if ARBISCAN_API_KEY is set
if [[ -z $ARBISCAN_API_KEY ]]; then
  echo -e "Error: ARBISCAN_API_KEY is not set in .env.\n"
  exit 1
fi

# Check if ARBITRUM_GOERLI_RPC_URL is set
if [[ -z $ARBITRUM_GOERLI_RPC_URL ]]; then
  echo -e "Error: ARBITRUM_GOERLI_RPC_URL is not set in .env.\n"
  exit 1
fi

# Check if DEPLOYER_KEY is set
if [[ -z $DEPLOYER_KEY ]]; then
  echo -e "Error: DEPLOYER_KEY is not set in .env.\n"
  exit 1
fi

# Get DEPLOYER_ADDRESS
DEPLOYER_ADDRESS=$(cast wallet address $DEPLOYER_KEY)
echo -e "Deployer Address: $DEPLOYER_ADDRESS\n"

# Get ETH balance in Wei
DEPLOYER_BALANCE_DEC=$(cast balance $DEPLOYER_ADDRESS --rpc-url $RPC_URL)

# Convert from Wei to Ether
DEPLOYER_BALANCE_ETH=$(cast from-wei $DEPLOYER_BALANCE_DEC)
echo -e "Deployer address balance is $DEPLOYER_BALANCE_ETH ETH.\n"

# Run forge scripts
forge script script/Arbitrum/upgrade/${UPGRADE_SCRIPT} --rpc-url $RPC_URL --verify --broadcast --verifier-url $VERIFIER_URL

echo -e "\nDeployer Address: $DEPLOYER_ADDRESS\n"
