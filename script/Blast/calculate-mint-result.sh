#!/usr/bin/env bash
set -e

CALCULATION_SCRIPT="01_calculateMintResult.s.sol"
CHAIN_ID=81457
RPC_URL=$BLAST_RPC_URL
export COLLECTION_ADDRESS=$1
export CORE_BLAST_ADDRESS="0x8113e6335ddf1e6227113b429cd1f57e8e007760"
export NUMBER_OF_MINTS=$2
export RANDOMNESS="$3,$4"
export PRICE_PER_MINT=$5

# Run forge scripts
forge script script/Blast/${CALCULATION_SCRIPT} --rpc-url $RPC_URL
