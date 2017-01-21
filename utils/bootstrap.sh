#!/usr/bin/env bash

sudo salt -N swarmmanager state.apply swarm.manager.first
sudo salt -N swarmmanager mine.update
sudo salt -N swarmmanager state.apply swarm.manager.drain
sudo salt -N swarmworker state.apply swarm.worker.join
