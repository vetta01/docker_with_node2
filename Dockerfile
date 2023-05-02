FROM node:10-alpine
#This image includes Node.js and npm. Dockerfile must begin with a FROM instruction.

#By default, the Docker Node image includes a non-root user 'node' that you can use to avoid 
# running your application container as root. It is recommended security practice to avoid 
# running container as root.
# we will therefore use the node user’s home directory as the working directory for our application 
# and set them as our user inside the container

# To fine-tune the permissions on your application code in the container, create the 
#node_modules subdirectory in /home/node along with the app directory. Creating these 
#directories will ensure that they have the correct permissions, which will be important 
#when you create local node modules in the container with npm install. In addition to 
#creating these directories, set ownership on them to your node user
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

# Next, set the working directory of the application to /home/node/app
WORKDIR /home/node/app

COPY package*.json ./

USER node

RUN npm install

COPY --chown=node:node . .

EXPOSE 8080

CMD [ "node", "app.js" ]
