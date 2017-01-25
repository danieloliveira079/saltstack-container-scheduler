# Salt Stack Container Scheduler

This project is a case study that aims to demonstrate the ability of using [Salt Stack](https://saltstack.com/) as a container scheduler and orchestrator that interacts with [Docker Swarm](https://www.docker.com/products/docker-swarm).

The components that compound the project are:

* Vagrant
 * 1 VM Salt Master
 * 3 VMs Salt Minions (1 Docker Swarm Manager and 2 Docker Swarm Workers)


* Salt Components
  * Salt Stack Master
  * Salt Stack API
  * Salt Stack Reactor
  * Salt Stack Minion  


* Docker Components
  * Docker Engine
  * Docker Swarm

The result is a Event Hub that will receive requests via Salt API and apply the desired states across the cluster of nodes. The possible states are:

* Create Docker Swarm Service
* Update Docker Swarm Service
* Scale Docker Swarm Service Replicas - Up and Down
* Delete Docker Swarm Service

One of the majors benefits of doing all the scheduling operations using a central API is that the Docker API is not exposed in any moment. Consequently only pre-defined events are allowed. That approach improves the containers management from a security point of view. Furthermore decreasing attacks surface due to the minimal exposure.

The access control can be easily configured using different kind of components: AWS Security Groups and Access Control, Firewall Rules or any other similar component available on the Cloud Provider you are using. The same can be achieved using bare metal hosts that have had Salt Stack installed and a similar network structure as demonstrated by the VMs presented by this project. For better results it is recommended that at least 1 Salt Master and 1 Salt Minion are part of the network and the minion has its key accepted by the Salt Master.

## Important

You might notice some important conventions over the project related specially about how nodes roles are defined and how the Salt Master can distinguish between Swarm Managers from Swarm Works when applying states.

During the Vagrant provisioning process a few config files are purposely synced with the right place for each VM. In case of the Salt Master the `./saltstack/etc/master.d` folder content is synced with `/etc/salt/master.d`. This is a Salt Stack convention that will instruct the Salt Master from where it must load its extra configurations when the service starts up. In our example the file `nodegroups.conf` is defining how nodes roles are match by the Salt Master.

The main configuration is stored in the `./saltstack/etc/master` and `./saltstack/etc/minion[1-3]` for the master and the minions respectively.

```
nodegroups:
  swarmmanager: 'G@roles:swarmmanager'
  swarmworker: 'G@roles:swarmworker'
```

Basically every Salt Minion that has within the [grains] config any of those roles will perform what it is designed for.

Below is an example of a Salt Minion grains that performs the Docker Swarm Manager role:

```
grains:
  roles:
    - swarmmanager
  hosting:
    - web
    - api
  environment:
     - development
  server: managersaltminion1.local
```

The same folder rules can be applied for the Salt Minions. All the content from `./saltstack/etc/minion.d` wil be synced with all the minions config folder.

The folders `./salstack/etc/ssl` and `./salstack/keys` are related to certificates for the [Salt API](https://docs.saltstack.com/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html) and keys for the master/minion [preseed](https://docs.saltstack.com/en/latest/topics/tutorials/preseed_key.html) process. It is out of the scope of this project to explain both concepts and usage.

## Salt Stack Pillar

"Salt pillar is a system that lets you define secure data that are ‘assigned’ to one or more minions using targets. Salt pillar data stores values such as ports, file paths, configuration parameters, and passwords." - [Salt Stack Website](https://docs.saltstack.com/en/getstarted/config/pillar.html)

All the pillars required for the project are stored under `./salstack/pillar` folder. This folder will be synced with `/srv/pillar` folder on the master.

Salt has a really nice feature called [Gitfs](https://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html). It allows you to keep your pillar or state files on a git repository. That way the server keeps checking for updates based on a configured interval. In our case we are running all locally and the Gitfs will not be used.

## Salt Stack States

"Salt State functions are what do the work in your Salt states, and are the most important thing to master when using SaltStack’s configuration management system." - [Salt Stack Website](https://docs.saltstack.com/en/getstarted/config/functions.html)

All the states required for the project are stored under `./salstack/salt` folder. This folder will be synced with `/srv/salt` folder on the master.

As mentioned previously you can use [Gitfs](https://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html) as the repository of your files.


## Utils

The `./utils` folder contains some useful commands and scripts that can be used for key generation, bootstrapping the environment, deployments via API and Docker Swarm commands.

## Provisioning

## Running

## Create Swarm Service

## Update Swarm Service

## Scale Swarm Service Up and Down

## Delete Swarm Service
