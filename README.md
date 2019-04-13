## Bootraping 
Before starting, you will need to pull all the images of Hyperledger fabric to your desktop and tag them as latest. We included a script to do this. By default it will try to pull in `1.3.0` but you can pull a custom version by adding the version as a parameter.
```bash
bash ./scripts/bootstrap.sh
```
## Starting
Starting this network requires you to run following command. This will automatically setup your docker network using docker-compose and install your chaincode.
```bash
bash ./scripts/startFabric.sh
```

## Stopping
Stopping this network requires you to run following commands. This will automatically all docker containers.
```bash
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
docker system prune
```
