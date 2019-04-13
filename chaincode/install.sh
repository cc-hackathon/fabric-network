#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

CHAINCODE_RECORDS=recordschaincode
CHAINCODE_VERSION=1.0
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
LANGUAGE=${1:-"node"}

cd $DIR
cd ./node
yarn
yarn run clean
yarn run build
CC_SRC_PATH=/opt/gopath/src/github.com/phr/node

# clean the keystore
rm -rf ./hfc-key-store

cd $DIR

# launch network; create channel and join peer to channel
#cd ../basic-network
cd ..

# Now launch the CLI container in order to install, instantiate chaincode
# and prime the ledger with our 10 cars
#docker-compose -f ./docker-compose.yml up -d cli.Registry

# Install chaincodes
docker exec -e "CORE_PEER_LOCALMSPID=RegistryMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Registry.com/users/Admin@Registry.com/msp" cli.Registry peer chaincode install -n "$CHAINCODE_RECORDS" -v "$CHAINCODE_VERSION" -p "$CC_SRC_PATH" -l "$LANGUAGE"
sleep 5
docker exec -e "CORE_PEER_LOCALMSPID=AppraiserMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Appraiser.com/users/Admin@Appraiser.com/msp" cli.Appraiser peer chaincode install -n "$CHAINCODE_RECORDS" -v "$CHAINCODE_VERSION" -p "$CC_SRC_PATH" -l "$LANGUAGE"
sleep 5

# Instantiate chaincodes
docker exec -e "CORE_PEER_LOCALMSPID=RegistryMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Registry.com/users/Admin@Registry.com/msp" cli.Registry peer chaincode instantiate -o orderer.mrtgexchg.com:7050 -C records -n "$CHAINCODE_RECORDS" -l "$LANGUAGE" -v "$CHAINCODE_VERSION" -c '{"function":"init","Args":["'$CHAINCODE_VERSION'"]}'
sleep 5

# Invoke chaincodes
docker exec -e "CORE_PEER_LOCALMSPID=RegistryMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Registry.com/users/Admin@Registry.com/msp" cli.Registry peer chaincode invoke -o orderer.mrtgexchg.com:7050 -C records -n "$CHAINCODE_RECORDS" -c '{"function":"initLedger","Args":[""]}'
