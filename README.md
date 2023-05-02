Project code for tutorial on integrating MongoDB into Node.js application using Mongoose: https://www.digitalocean.com/community/tutorials/how-to-integrate-mongodb-with-your-node-application

Points about Docker compose file
1. Service in Compose : A service in Compose is a running container and services keyword in your docker-compose.yml file contain information about how each container image will run. 
2. If you have multiple containers in your compose and one container is depenedent on other then you need to add a tool to your project called wait-for to ensure that your application only attempts to connect to your 2nd container once the container startup tasks are complete. Though Compose allows you to specify dependencies between services using the depends_on option, this order is based on whether the container is running rather than its readiness.

The NODEJS service definition includes the following options:
build: This defines the configuration options, including the context and dockerfile, that will be applied when Compose builds the application image. If you wanted to use an existing image from a registry like Docker Hub, you could use the image instruction instead, with information about your username, repository, and image tag.

context: This defines the build context for the image build — in this case, the current project directory.

dockerfile: This specifies the Dockerfile in your current project directory as the file Compose will use to build the application image. 

restart: This defines the restart policy. The default is no, but you have set the container to restart unless it is stopped.

env_file: This tells Compose that you would like to add environment variables from a file called .env, located in your build context.

environment: Using this option allows you to add the Mongo connection settings you defined in the .env file. Note that you are not setting NODE_ENV to development, since this is Express’s default behavior if NODE_ENV is not set. When moving to production, you can set this to production to enable view caching and less verbose error messages. Also note that you have specified the db database container as the host

ports: This maps port 80 on the host to port 8080 on the container.


volumes: You are including two types of mounts here:

The first is a bind mount that mounts your application code on the host to the /home/node/app directory on the container. This will facilitate rapid development, since any changes you make to your host code will be populated immediately in the container.

The second is a named volume, node_modules. When Docker runs the npm install instruction listed in the application Dockerfile, npm will create a new node_modules directory on the container that includes the packages required to run the application. The bind mount you just created will hide this newly created node_modules directory, however. Since node_modules on the host is empty, the bind will map an empty directory to the container, overriding the new node_modules directory and preventing your application from starting. The named node_modules volume solves this problem by persisting the contents of the /home/node/app/node_modules directory and mounting it to the container, hiding the bind.

networks: This specifies that your application service will join the app-network network, which you will define at the bottom of the file.

command: This option lets you set the command that should be executed when Compose runs the image. Note that this will override the CMD instruction that you set in our application Dockerfile. Here, you are running the application using the wait-for script, which will poll the db service on port 27017 to test whether the database service is ready. Once the readiness test succeeds, the script will execute the command you have set, /home/node/app/node_modules/.bin/nodemon app.js, to start the application with nodemon. This will ensure that any future changes you make to your code are reloaded without your having to restart the application.



The DB service included below option:
image : To create this service, Compose will pull the 4.1.8-xenial Mongo image from Docker Hub. 
MONGO_INITDB_ROOT_USERNAME, MONGO_INITDB_ROOT_PASSWORD: The mongo image makes these environment variables available so that you can modify the initialization of your database instance. MONGO_INITDB_ROOT_USERNAME and MONGO_INITDB_ROOT_PASSWORD together create a root user in the admin authentication database and ensure that authentication is enabled when the container starts. You have set MONGO_INITDB_ROOT_USERNAME and MONGO_INITDB_ROOT_PASSWORD using the values from your .env file, which you pass to the db service using the env_file option. Doing this means that your sammy application user will be a root user on the database instance, with access to all the administrative and operational privileges of that role. When working in production, you will want to create a dedicated application user with appropriately scoped privileges.

Note: Keep in mind that these variables will not take effect if you start the container with an existing data directory in place.



About volume and network definitions 
The user-defined bridge network app-network enables communication between your containers since they are on the same Docker daemon host. his streamlines traffic and communication within the application, as it opens all ports between containers on the same bridge network, while exposing no ports to the outside world. Thus, your db and nodejs containers can communicate with each other, and you only need to expose port 80 for front-end access to the application.

Your top-level volumes key defines the volumes dbdata and node_modules. When Docker creates volumes, the contents of the volume are stored in a part of the host filesystem, /var/lib/docker/volumes/, that’s managed by Docker. The contents of each volume are stored in a directory under /var/lib/docker/volumes/ and get mounted to any container that uses the volume. In this way, the shark information data that your users will create will persist in the dbdata volume even if you remove and recreate the db container.

RUN docker compose : docker-compose up -d 
Check status of your containers : docker-compose ps
You can access your app FE on : localhost:80 

Stop and remove your containers and network
docker-compose down
Note that you are not including the --volumes option; hence, your dbdata volume is not removed.