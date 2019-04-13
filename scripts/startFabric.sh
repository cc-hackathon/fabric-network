#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# clean the keystore
rm -rf ./hfc-key-store

cd $DIR

# launch network; create channel and join peer to channel
cd ../basic-network
bash ./start.sh

#cd ../chaincode
#bash ./install.sh
