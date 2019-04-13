#!/bin/bash

export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down

#remove old images
echo "REMOVE ALL OLD IMAGES"
docker images | grep "dev-" | awk '{print $3}' | xargs docker rmi -f

docker-compose -f docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
#sleep 10

# Create the channels
docker exec -e "CORE_PEER_LOCALMSPID=RegistryMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@Registry.com/msp" peer0.Registry.com peer channel create -o orderer.mrtgexchg.com:7050 -c records -f /etc/hyperledger/configtx/records.tx

# Join the channels.
docker exec -e "CORE_PEER_LOCALMSPID=RegistryMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@Registry.com/msp" peer0.Registry.com peer channel join -b records.block

docker exec -e "CORE_PEER_LOCALMSPID=AppraiserMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@Appraiser.com/msp" peer0.Appraiser.com peer channel fetch 0 records.block -o orderer.mrtgexchg.com:7050 -c records
docker exec -e "CORE_PEER_LOCALMSPID=AppraiserMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@Appraiser.com/msp" peer0.Appraiser.com peer channel join -b records.block

sleep 10

# Update anchor peers
#docker exec -e "CORE_PEER_LOCALMSPID=RegistryMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@Registry.com/msp" peer0.Registry.com peer channel update -o orderer.mrtgexchg.com:7050 -c records -f /etc/hyperledger/configtx/RegistryMSPanchors.tx
