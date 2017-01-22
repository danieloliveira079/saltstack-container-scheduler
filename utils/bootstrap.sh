#!/usr/bin/env bash

printf "=======>Installing Docker on Swarm Manager\n"
sudo salt -N swarmmanager state.apply docker.engine
printf "=======>Initiating Swarm Manager\n"
sudo salt -N swarmmanager state.apply swarm.manager.first
printf "=======>Updating Salt Mine\n"
sudo salt -N swarmmanager mine.update
printf "=======>Draining Swarm Manager\n"
sudo salt -N swarmmanager state.apply swarm.manager.drain
printf "=======>Installing Docker on Swarm Workers\n"
sudo salt -N swarmworker state.apply docker.engine
printf "=======>Joining Swarm Workers\n"
sudo salt -N swarmworker state.apply swarm.worker.join
