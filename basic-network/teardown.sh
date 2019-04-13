#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0

# Shut down the Docker containers for the system tests.
docker-compose -f ./docker-compose.yml kill && docker-compose -f ./docker-compose.yml down

# remove the local state
rm -f ~/.hfc-key-store/*

# remove chaincode docker images
docker rmi $(docker images dev-* -q)
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)

# Your system is now clean
