# TASK

## 1) Develop local Docker environment (Docker SWARM mode)
- use Docker EE with one month trial license
- install **UCP** and **DTR**
- create required repos (for application) in **DTR**

## 2) Integrate Jenkins to Docker swarm
- create the Job which can build Java Spring App ( https://github.com/sqshq/PiggyMetrics )  
- set Docker container as Jenkins slave (container must start before the build)

## 3) deploy the application as Docker stack app in swarm cluster

The infrastructure contains 4 nodes:
- **jenkinsmaster** has installed Jenkins for jobs runs. **swarmmaster** node is a **jenkinsmaster**'s slave where job will run; 
- **swarmmaster** has installed Docker Enterprise Edition with *Docker Swarm*, *Docker Compose*, *Universal Control Plane* (**UCP**) and *Docker Trusted Registry* (**DTR**). This node is a **MASTER NODE** of the *Docker Swarm* cluster;
- **swarmslave1** has installed Docker Enterprise Edition with *Docker Swarm* and *Docker Compose*. This node is a **WORKER NODE** of the *Docker Swarm* cluster;
- **swarmslave2** has installed Docker Enterprise Edition with *Docker Swarm* and *Docker Compose*. This node is a **WORKER NODE** of the *Docker Swarm* cluster.


The infrastructure is installed from a vagrantfile:
- **jenkinsmaster** bootstraps from **jenkins_install.sh** script;
- **swarmmaster**, **swarmslave1**, **swarmslave2** bootstrap from **docker_install.sh** script.


NOTE: helpful link for with personal Docker Entreprise Edition set up information https://store.docker.com/my-content
![](/TASK_4/scr/ee_setup.jpg)

## When bootstrap process has been done need to install **UCP** and **DTR** on the **swarmmaster** node.
### UCP install:
    $ docker image pull docker/ucp:2.2.4
    $ docker container run --rm -it --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp:2.2.4 install --host-address 10.23.13.250 --interactive
#### Output:
    INFO[0000] Verifying your system is compatible with UCP 2.2.4 (168ec746e)
    INFO[0000] Your engine version 17.06.2-ee-7, build 925df35 (3.10.0-693.21.1.el7.x86_64) is compatible
    Admin Username: admin
    Admin Password:
    Confirm Admin Password:
    INFO[0045] Pulling required images... (this may take a while)
    INFO[0045] Pulling docker/ucp-agent:2.2.4
    INFO[0049] Pulling docker/ucp-cfssl:2.2.4
    INFO[0053] Pulling docker/ucp-auth:2.2.4
    INFO[0057] Pulling docker/ucp-hrm:2.2.4
    INFO[0062] Pulling docker/ucp-dsinfo:2.2.4
    INFO[0119] Pulling docker/ucp-etcd:2.2.4
    INFO[0123] Pulling docker/ucp-swarm:2.2.4
    INFO[0128] Pulling docker/ucp-compose:2.2.4
    INFO[0134] Pulling docker/ucp-controller:2.2.4
    INFO[0140] Pulling docker/ucp-auth-store:2.2.4
    INFO[0146] Pulling docker/ucp-metrics:2.2.4
    INFO[0019] All required images are present
    WARN[0019] None of the hostnames we'll be using in the UCP certificates [swarmmaster 127.0.0.1 172.17.0.1 10.23.13.250] contain a domain component.
    Your generated certs may fail TLS validation unless you only use one of these shortnames or IPs to connect.  You can use the --san flag to add more aliases
    You may enter additional aliases (SANs) now or press enter to proceed with the above list.
    Additional aliases: 10.23.13.250:443
    INFO[0000] Initializing a new swarm at 10.23.13.250
    INFO[0004] Establishing mutual Cluster Root CA with Swarm
    INFO[0007] Installing UCP with host address 10.23.13.250 - If this is incorrect, please specify an alternative address with the '--host-address' flag
    INFO[0007] Generating UCP Client Root CA
    INFO[0007] Deploying UCP Service
    INFO[0042] Installation completed on swarmmaster (node ywj6yqao4a4r6itkohg7vkobc)
    INFO[0042] UCP Instance ID: hxz5kf9atspjwnoa5oqlonigv
    INFO[0042] UCP Server SSL: SHA-256 Fingerprint=94:E4:BB:69:25:7B:F5:5B:11:E9:98:77:BF:C8:F2:EE:77:9F:45:6E:C0:4C:FE:F0:9B:F2:38:80:6F:41:5A:9A
    INFO[0042] Login to UCP at https://10.23.13.250:443
    INFO[0042] Username: administrator
    INFO[0042] Password: (your admin password)
    

#### UCP web UI login with administrator credentials
![](/TASK_4/scr/ucp_login.png)

#### Upload license from downloaded **docker_subscription.lic** file
![](/TASK_4/scr/ucp_upload_license.jpg)

### Dashboard:
![](/TASK_4/scr/ee_dashboard.jpg)
### We can see license information in few steeps
- Navigate to the Admin Settings page and in the left pane and click  License.

![](/TASK_4/scr/ee_license.jpg)

### Also we can see and change Cluster configuration
- For example change Controller port value to 1443.

![](/TASK_4/scr/cluster_configuration.jpg)

### DTR install:
    $ docker run -it --rm docker/dtr install  --ucp-node swarmmaster  --ucp-username administrator  --ucp-url http://swarmmaster:1443  --ucp-insecure-tls
#### Output:
    Unable to find image 'docker/dtr:latest' locally
    latest: Pulling from docker/dtr
    605ce1bd3f31: Already exists
    3229f5297e59: Pull complete
    311610a93755: Pull complete
    33fb3c0b5eca: Pull complete
    Digest: sha256:713cd5692136d203d10a94084dca13c1918f3ef25543e3908d9358dad83e2aac
    Status: Downloaded newer image for docker/dtr:latest
    INFO[0000] Beginning Docker Trusted Registry installation
    ucp-password:
    INFO[0005] Validating UCP cert
    INFO[0005] Connecting to UCP
    INFO[0005] Only one available UCP node detected. Picking UCP node 'swarmmaster'
    INFO[0005] Searching containers in UCP for DTR replicas
    INFO[0005] Searching containers in UCP for DTR replicas
    INFO[0005] verifying [80 443] ports on swarmmaster
    INFO[0010] starting phase 2
    INFO[0000] Validating UCP cert
    INFO[0000] Connecting to UCP
    INFO[0000] Verifying your system is compatible with DTR
    INFO[0000] Checking if the node is okay to install on
    INFO[0000] Creating network: dtr-ol
    INFO[0000] Connecting to network: dtr-ol
    INFO[0000] Waiting for phase2 container to be known to the Docker daemon
    INFO[0001] Starting UCP connectivity test
    INFO[0001] UCP connectivity test passed
    INFO[0001] Setting up replica volumes...
    INFO[0001] Creating initial CA certificates
    INFO[0001] Bootstrapping rethink...
    INFO[0001] Creating dtr-rethinkdb-daa7b23c3a61...
    INFO[0012] Establishing connection with Rethinkdb
    INFO[0013] Waiting for database dtr2 to exist
    INFO[0013] Establishing connection with Rethinkdb
    INFO[0017] Generated TLS certificate.                    dnsNames=[*.com *.*.com example.com *.dtr *.*.dtr] domains=[*.com *.*.com 172.17.0.1 example.com *.dtr *.*.dtr] ipAddresses=[172.17.0.1]
    INFO[0017] License config copied from UCP.
    INFO[0017] Migrating db...
    INFO[0000] Establishing connection with Rethinkdb
    INFO[0000] Migrating database schema                     fromVersion=0 toVersion=8
    INFO[0004] Waiting for database notaryserver to exist
    INFO[0005] Waiting for database notarysigner to exist
    INFO[0006] Waiting for database jobrunner to exist
    INFO[0007] Migrated database from version 0 to 8
    INFO[0025] Starting all containers...
    INFO[0025] Getting container configuration and starting containers...
    INFO[0026] Recreating dtr-rethinkdb-daa7b23c3a61...
    INFO[0030] Creating dtr-registry-daa7b23c3a61...
    INFO[0038] Creating dtr-garant-daa7b23c3a61...
    INFO[0044] Creating dtr-api-daa7b23c3a61...
    INFO[0087] Creating dtr-notary-server-daa7b23c3a61...
    INFO[0095] Recreating dtr-nginx-daa7b23c3a61...
    INFO[0102] Creating dtr-jobrunner-daa7b23c3a61...
    INFO[0128] Creating dtr-notary-signer-daa7b23c3a61...
    INFO[0136] Creating dtr-scanningstore-daa7b23c3a61...
    INFO[0144] Trying to get the kv store connection back after reconfigure
    INFO[0144] Establishing connection with Rethinkdb
    INFO[0145] Verifying auth settings...
    INFO[0146] Successfully registered dtr with UCP
    INFO[0146] Establishing connection with Rethinkdb
    INFO[0146] Background tag migration started
    INFO[0146] Installation is complete
    INFO[0146] Replica ID is set to: daa7b23c3a61
    INFO[0146] You can use flag '--existing-replica-id daa7b23c3a61' when joining other replicas to your Docker Trusted Registry Cluster

### Connect WORKER NODES to MASTER NODE:
    docker swarm join --token SWMTKN-1-54gtmj7jweybi9hghhmzz3pejl2pe7h7v63knejczreer4z2w4-1l5673p54ydoag33oc5ipn0uh 10.23.13.250:2377
#### Output:
    This node joined a swarm as a worker.

### Jenkins Jobs's configuration:

- Source Code Managment

![](/TASK_4/scr/job_scm.jpg)

- Build

![](/TASK_4/scr/job_build.jpg)

### Jenkins Jobs's Console Output:
    Console Output
    Started by user anonymous
    Building remotely on swarmmaster (build-server) in workspace /var/lib/jenkins/workspace/build
    [WS-CLEANUP] Deleting project workspace...
    [WS-CLEANUP] Done
    Cloning the remote Git repository
    Cloning repository https://github.com/sqshq/PiggyMetrics.git
    > git init /var/lib/jenkins/workspace/build # timeout=10
    Fetching upstream changes from https://github.com/sqshq/PiggyMetrics.git
    > git --version # timeout=10
    using GIT_ASKPASS to set credentials
    > git fetch --tags --progress https://github.com/sqshq/PiggyMetrics.git +refs/heads/*:refs/remotes/origin/*
    > git config remote.origin.url https://github.com/sqshq/PiggyMetrics.git # timeout=10
    > git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
    > git config remote.origin.url https://github.com/sqshq/PiggyMetrics.git # timeout=10
    Fetching upstream changes from https://github.com/sqshq/PiggyMetrics.git
    using GIT_ASKPASS to set credentials
    > git fetch --tags --progress https://github.com/sqshq/PiggyMetrics.git +refs/heads/*:refs/remotes/origin/*
    > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
    > git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
    Checking out Revision 914ed4781a1999a70dcdc5e2d4a5133ae296f4c6 (refs/remotes/origin/master)
    > git config core.sparsecheckout # timeout=10
    > git checkout -f 914ed4781a1999a70dcdc5e2d4a5133ae296f4c6
    Commit message: "Merge pull request #17 from ddubson/master"
    > git rev-list --no-walk 914ed4781a1999a70dcdc5e2d4a5133ae296f4c6 # timeout=10
    [build] $ /bin/sh -xe /tmp/jenkins6828677510483824087.sh
    + export CONFIG_SERVICE_PASSWORD
    + export NOTIFICATION_SERVICE_PASSWORD
    + export STATISTICS_SERVICE_PASSWORD
    + export ACCOUNT_SERVICE_PASSWORD
    + export MONGODB_PASSWORD
    [build] $ /var/lib/jenkins/tools/hudson.tasks.Maven_MavenInstallation/maven3.5.3/bin/mvn compile
    [INFO] Scanning for projects...
    [INFO] ------------------------------------------------------------------------
    [INFO] Reactor Build Order:
    [INFO]
    [INFO] config                                                             [jar]
    [INFO] monitoring                                                         [jar]
    [INFO] registry                                                           [jar]
    [INFO] gateway                                                            [jar]
    [INFO] auth-service                                                       [jar]
    [INFO] account-service                                                    [jar]
    [INFO] statistics-service                                                 [jar]
    [INFO] notification-service                                               [jar]
    [INFO] piggymetrics                                                       [pom]
    [INFO]
    [INFO] ----------------------< com.piggymetrics:config >-----------------------
    [INFO] Building config 1.0.0-SNAPSHOT                                     [1/9]
    [INFO] --------------------------------[ jar ]---------------------------------
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ config ---
    [INFO] Using 'UTF-8' encoding to copy filtered resources.
    [INFO] Copying 2 resources
    [INFO] Copying 7 resources
    [INFO]
    [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ config ---
    [INFO] Changes detected - recompiling the module!
    [INFO] Compiling 1 source file to /var/lib/jenkins/workspace/build/config/target/classes
    [INFO]
    [INFO] --------------------< com.piggymetrics:monitoring >---------------------
    [INFO] Building monitoring 0.0.1-SNAPSHOT                                 [2/9]
    [INFO] --------------------------------[ jar ]---------------------------------
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ monitoring ---
    [INFO] Using 'UTF-8' encoding to copy filtered resources.
    [INFO] Copying 0 resource
    [INFO] Copying 1 resource
    [INFO]
    [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ monitoring ---
    [INFO] Changes detected - recompiling the module!
    [INFO] Compiling 1 source file to /var/lib/jenkins/workspace/build/monitoring/target/classes
    [INFO]
    [INFO] ---------------------< com.piggymetrics:registry >----------------------
    [INFO] Building registry 0.0.1-SNAPSHOT                                   [3/9]
    [INFO] --------------------------------[ jar ]---------------------------------
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ registry ---
    [INFO] Using 'UTF-8' encoding to copy filtered resources.
    [INFO] Copying 0 resource
    [INFO] Copying 1 resource
    [INFO]
    [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ registry ---
    [INFO] Changes detected - recompiling the module!
    [INFO] Compiling 1 source file to /var/lib/jenkins/workspace/build/registry/target/classes
    [INFO]
    [INFO] ----------------------< com.piggymetrics:gateway >----------------------
    [INFO] Building gateway 1.0-SNAPSHOT                                      [4/9]
    [INFO] --------------------------------[ jar ]---------------------------------
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ gateway ---
    [INFO] Using 'UTF-8' encoding to copy filtered resources.
    [INFO] Copying 0 resource
    [INFO] Copying 49 resources
    [INFO]
    [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ gateway ---
    [INFO] Changes detected - recompiling the module!
    [INFO] Compiling 1 source file to /var/lib/jenkins/workspace/build/gateway/target/classes
    [INFO]
    [INFO] -------------------< com.piggymetrics:auth-service >--------------------
    [INFO] Building auth-service 1.0-SNAPSHOT                                 [5/9]
    [INFO] --------------------------------[ jar ]---------------------------------
    [INFO]
    [INFO] --- jacoco-maven-plugin:0.7.6.201602180812:prepare-agent (default) @ auth-service ---
    [INFO] argLine set to -javaagent:/var/lib/jenkins/.m2/repository/org/jacoco/org.jacoco.agent/0.7.6.201602180812/org.jacoco.agent-0.7.6.201602180812-runtime.jar=destfile=/var/lib/jenkins/workspace/build/auth-service/target/jacoco.exec
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ auth-service ---
    [INFO] Using 'UTF-8' encoding to copy filtered resources.
    [INFO] Copying 0 resource
    [INFO] Copying 1 resource
    [INFO]
    [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ auth-service ---
    [INFO] Changes detected - recompiling the module!
    [INFO] Compiling 7 source files to /var/lib/jenkins/workspace/build/auth-service/target/classes
    [INFO]
    [INFO] ------------------< com.piggymetrics:account-service >------------------
    [INFO] Building account-service 1.0-SNAPSHOT                              [6/9]
    [INFO] --------------------------------[ jar ]---------------------------------
    [INFO]
    [INFO] --- jacoco-maven-plugin:0.7.6.201602180812:prepare-agent (default) @ account-service ---
    [INFO] argLine set to -javaagent:/var/lib/jenkins/.m2/repository/org/jacoco/org.jacoco.agent/0.7.6.201602180812/org.jacoco.agent-0.7.6.201602180812-runtime.jar=destfile=/var/lib/jenkins/workspace/build/account-service/target/jacoco.exec
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ account-service ---
    [INFO] Using 'UTF-8' encoding to copy filtered resources.
    [INFO] Copying 0 resource
    [INFO] Copying 1 resource
    [INFO]
    [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ account-service ---
    [INFO] Changes detected - recompiling the module!
    [INFO] Compiling 15 source files to /var/lib/jenkins/workspace/build/account-service/target/classes
    [INFO]
    [INFO] ----------------< com.piggymetrics:statistics-service >-----------------
    [INFO] Building statistics-service 1.0-SNAPSHOT                           [7/9]
    [INFO] --------------------------------[ jar ]---------------------------------
    [INFO]
    [INFO] --- jacoco-maven-plugin:0.7.6.201602180812:prepare-agent (default) @ statistics-service ---
    [INFO] argLine set to -javaagent:/var/lib/jenkins/.m2/repository/org/jacoco/org.jacoco.agent/0.7.6.201602180812/org.jacoco.agent-0.7.6.201602180812-runtime.jar=destfile=/var/lib/jenkins/workspace/build/statistics-service/target/jacoco.exec
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ statistics-service ---
    [INFO] Using 'UTF-8' encoding to copy filtered resources.
    [INFO] Copying 0 resource
    [INFO] Copying 1 resource
    [INFO]
    [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ statistics-service ---
    [INFO] Changes detected - recompiling the module!
    [INFO] Compiling 21 source files to /var/lib/jenkins/workspace/build/statistics-service/target/classes
    [INFO]
    [INFO] ---------------< com.piggymetrics:notification-service >----------------
    [INFO] Building notification-service 1.0.0-SNAPSHOT                       [8/9]
    [INFO] --------------------------------[ jar ]---------------------------------
    [INFO]
    [INFO] --- jacoco-maven-plugin:0.7.6.201602180812:prepare-agent (default) @ notification-service ---
    [INFO] argLine set to -javaagent:/var/lib/jenkins/.m2/repository/org/jacoco/org.jacoco.agent/0.7.6.201602180812/org.jacoco.agent-0.7.6.201602180812-runtime.jar=destfile=/var/lib/jenkins/workspace/build/notification-service/target/jacoco.exec
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ notification-service ---
    [INFO] Using 'UTF-8' encoding to copy filtered resources.
    [INFO] Copying 0 resource
    [INFO] Copying 1 resource
    [INFO]
    [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ notification-service ---
    [INFO] Changes detected - recompiling the module!
    [INFO] Compiling 16 source files to /var/lib/jenkins/workspace/build/notification-service/target/classes
    [INFO]
    [INFO] -------------------< com.piggymetrics:piggymetrics >--------------------
    [INFO] Building piggymetrics 1.0-SNAPSHOT                                 [9/9]
    [INFO] --------------------------------[ pom ]---------------------------------
    [INFO] ------------------------------------------------------------------------
    [INFO] Reactor Summary:
    [INFO]
    [INFO] config 1.0.0-SNAPSHOT .............................. SUCCESS [  7.577 s]
    [INFO] monitoring 0.0.1-SNAPSHOT .......................... SUCCESS [  2.480 s]
    [INFO] registry 0.0.1-SNAPSHOT ............................ SUCCESS [  0.799 s]
    [INFO] gateway ............................................ SUCCESS [  0.684 s]
    [INFO] auth-service ....................................... SUCCESS [  1.975 s]
    [INFO] account-service .................................... SUCCESS [  1.447 s]
    [INFO] statistics-service ................................. SUCCESS [  2.443 s]
    [INFO] notification-service 1.0.0-SNAPSHOT ................ SUCCESS [  1.818 s]
    [INFO] piggymetrics 1.0-SNAPSHOT .......................... SUCCESS [  0.000 s]
    [INFO] ------------------------------------------------------------------------
    [INFO] BUILD SUCCESS
    [INFO] ------------------------------------------------------------------------
    [INFO] Total time: 24.848 s
    [INFO] Finished at: 2018-03-29T13:55:33Z
    [INFO] ------------------------------------------------------------------------
    [build] $ /bin/sh -xe /tmp/jenkins8704831276945621001.sh
    + docker stack rm metrics
    Removing service metrics_notification-mongodb
    Removing service metrics_notification-service
    Removing service metrics_statistics-service
    Removing service metrics_account-service
    Removing service metrics_config
    Removing service metrics_statistics-mongodb
    Removing service metrics_monitoring
    Removing service metrics_auth-mongodb
    Removing service metrics_rabbitmq
    Removing service metrics_registry
    Removing service metrics_auth-service
    Removing service metrics_gateway
    Removing service metrics_account-mongodb
    Removing network metrics_default
    + sleep 10
    + docker stack deploy -c /var/lib/jenkins/docker-compose.yml metrics
    Ignoring unsupported options: restart
    
    Creating network metrics_default
    Creating service metrics_statistics-mongodb
    Creating service metrics_rabbitmq
    Creating service metrics_notification-service
    Creating service metrics_account-service
    Creating service metrics_config
    Creating service metrics_registry
    Creating service metrics_statistics-service
    Creating service metrics_monitoring
    Creating service metrics_gateway
    Creating service metrics_auth-mongodb
    Creating service metrics_account-mongodb
    Creating service metrics_auth-service
    Creating service metrics_notification-mongodb
    ++ docker ps -a -q
    + docker rm -f 8da17bf2f737 ea5a6c6d40f6 e3b444e9d09b 407a45368fa6 42f2a0d32e06 eb7ec0afe48f 3aac3353239a 8c20c363527b 906412fbfb7d 1e5ea422623d b2a066eefae6 71ba274694c9 d7a086575caf 335c0037c9b7 5b5b5d5a5576 0c6ed667106a 7bedc9b8f096 ec248d0a59f2 9e8e722c8867 6f2336ade589
    8da17bf2f737
    ea5a6c6d40f6
    e3b444e9d09b
    407a45368fa6
    42f2a0d32e06
    eb7ec0afe48f
    3aac3353239a
    8c20c363527b
    906412fbfb7d
    1e5ea422623d
    b2a066eefae6
    71ba274694c9
    d7a086575caf
    335c0037c9b7
    5b5b5d5a5576
    0c6ed667106a
    7bedc9b8f096
    ec248d0a59f2
    9e8e722c8867
    6f2336ade589
    + docker service ls
    ID                  NAME                           MODE                REPLICAS            IMAGE                                            PORTS
    0ifmie95wvm6        metrics_notification-service   replicated          1/1                 sqshq/piggymetrics-notification-service:latest
    0sj7dgcdf9fd        metrics_statistics-service     replicated          1/1                 sqshq/piggymetrics-statistics-service:latest
    12fxz67ctm4x        metrics_account-service        replicated          1/1                 sqshq/piggymetrics-account-service:latest
    35jtf03hqbcb        ucp-agent-win                  global              0/0                 docker/ucp-agent-win:2.2.7
    4dsyuibr3ply        metrics_monitoring             replicated          1/1                 sqshq/piggymetrics-monitoring:latest             *:8989->8989/tcp,*:9000->8080/tcp
    4lwceop91rw6        metrics_auth-service           replicated          1/1                 sqshq/piggymetrics-auth-service:latest
    fkxjxpbnzsvz        ucp-agent                      global              2/3                 docker/ucp-agent:2.2.7
    g0r3p48rnry6        metrics_config                 replicated          1/1                 sqshq/piggymetrics-config:latest
    jniespvgec95        metrics_account-mongodb        replicated          1/1                 sqshq/piggymetrics-mongodb:latest
    nog39wy91103        metrics_gateway                replicated          1/1                 sqshq/piggymetrics-gateway:latest                *:80->4000/tcp
    rxwyxij6phf6        metrics_auth-mongodb           replicated          1/1                 sqshq/piggymetrics-mongodb:latest
    s32ofvllgge4        ucp-agent-s390x                global              0/0                 docker/ucp-agent-s390x:2.2.7
    scrmkrhfy2cy        metrics_statistics-mongodb     replicated          1/1                 sqshq/piggymetrics-mongodb:latest
    v1jcpefvqubv        metrics_registry               replicated          1/1                 sqshq/piggymetrics-registry:latest               *:8761->8761/tcp
    yf5jb5pi8omk        metrics_notification-mongodb   replicated          1/1                 sqshq/piggymetrics-mongodb:latest
    zj3cc55odg0t        metrics_rabbitmq               replicated          1/1                 rabbitmq:3-management                            *:15672->15672/tcp
    Finished: SUCCESS

### Docker EE Dashboard -> Services
![](/TASK_4/scr/ee_services.jpg)
