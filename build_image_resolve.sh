#! /bin/bash

docker build -t jjleewustledu/niftyresolve-image:construct_resolved -f ${DOCKER_HOME}/NiftyResolve/Dockerfile ${DOCKER_HOME}/NiftyResolve
