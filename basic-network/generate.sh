#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_RECORDS=records

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile MRTGEXCHGOrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transactions
configtxgen -profile RecordsChannel -outputCreateChannelTx ./config/records.tx -channelID $CHANNEL_RECORDS
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transactions
configtxgen -profile RecordsChannel -outputAnchorPeersUpdate ./config/RegistryMSPanchors.tx -channelID $CHANNEL_RECORDS -asOrg RegistryMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for HospitalMSP..."
  exit 1
fi
