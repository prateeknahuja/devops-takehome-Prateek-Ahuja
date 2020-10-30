#!/bin/bash
#Run the gkeconnect docker container and shell into it. We are passing the variables.auto.tfvars as an environment file so that we can access
#the cluster info using the environment variables.  
docker run -it --env-file env.txt gkeconnect:local sh