# WIP - Documentation in progress

# Salt Stack Container Scheduler

This project is a case study that aims to demonstrate the ability of using [Salt Stack](https://saltstack.com/) as a container scheduler and orchestrator that interacts with [Docker Swarm](https://www.docker.com/products/docker-swarm) via Salt API.

The components and services that are part of this project are listed below:

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

In a real case scenario where the network is hosted on a cloud provider like Awazon, GCE or Azure, - [ ] he access control to the cluster network could be easily configured using different kind of components: AWS Security Groups and Access Control, Firewall Rules or any other similar component available on the Cloud Provider you are using. The same can be achieved using bare metal hosts that have had Salt Stack installed and a similar network structure as demonstrated by the VMs presented by this project. For better results it is recommended that at least 1 Salt Master and 1 Salt Minion are part of the network and the minion has its key accepted by the Salt Master.

## Important

You might notice some important conventions over the project related specially about how nodes roles are defined and how the Salt Master can distinguish between Swarm Managers from Swarm Works when applying states.

During the Vagrant provisioning process a few config files are purposely synced with the right place for each VM. In case of the Salt Master the `./saltstack/etc/master.d` folder content is synced with `/etc/salt/master.d`. This is a Salt Stack convention that will instruct the Salt Master from where it must load its extra configurations when the service starts up. In our example the file `nodegroups.conf` is defining how nodes roles are match by the Salt Master. Also the `reactor.conf` and `salt-api.conf` files are extremely important. The define respectively how events the reactor must handle and how the API is exposed in terms of endpoints and SSL certificates.

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

As mentioned previously the VMs provisioning are handled by Vagrant. In order to bring them to a operational state just run:

`$ vagrant up --provision`

The whole operation will take some time, specially if you don't have the box described in the the Vagrantfile.

Using the `:salt` provider all the Salt Master and Minion packages are installed during the provisioning process in addition the master is seeded with all the minions keys. This removes the necessity of having to accept the minions keys either manually or setting the master to accept minions keys automatically. Which is not recommended in a real world scenario.

After the completion of the process you can check the status of the machines running:

`$ vagrant status`

The status from all listed machines must be `Running`. If that is not what you get you can restart the process and check what went run. Before doing that run `$ vagrant halt` to turn off all the running instances.

## Boostrapping

The first step after have successfully provisioned the VMs is to boostrap the cluster. This process will install all the dependencies and required packages.

In order to make this process less tedious there is an script named `./utils/bootstrap.sh`. The required steps are:

* `$ vagrant ssh swarm_saltmaster`
* `$ cd utils`
* `./bootstrap.sh`

from this point the Salt Master will apply the desired states to all the machines according to its grains configurations. The process uses the states files located under `./saltstack/salt/` folder. Specifically to the boostrapping the following steps must be ran:

* Install Docker Engine
* Update Salt Mine information
* Initiate a Docker Swarm Cluster - Swarm Manager
* Drain Docker Swarm Manager from the cluster
* Join to the Docker Swarm Cluster - Swarm Workers

## Create Swarm Service

If all the previously steps were concluded successfully you are now able start running containers across your cluster.

All the operations are performed via Salt API. The simplest way you can interact with it is using the `curl` command line tool. The command below will create a service called `front-end`. As you might notice that name matches the root element presented in the `./saltstack/pillar/apps.front-end.sls`.

For the purpose of this project we are using this as a convention.

`curl -s -H "Content-Type: application/json" -d '{"service": "front-end", "environment":"development", "secretkey":"JHc3pJDMwRCmVVTw1nqEY9zPNDUJ2gzY6cXvOL17fHgO" }' -k "https://10.0.0.110:8080/hook/swarm/create"`

If we split the command and its arguments we can highlight the content of the `-d`. Those values will be used by the reactor and api components when looking for the states and pillars that must be used when applying the state. In this case we are instructing our master to apply the `create` state. The endpoint `/hook/swarm/create` specifies that.

You will notice a `{ success }` response. The success message just represent that the API has received the request and it was routed to the reactor component. Keep in mind that even after a success response you process can fail due to any abnormally.

The operation can take sometime to get completed since the docker image used by the service is not yet presented in the cluster.

## Update Swarm Service

## Scale Swarm Service Up and Down

## Delete Swarm Service
