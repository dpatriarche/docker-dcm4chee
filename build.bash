#!/bin/bash
set -v

docker.io rmi dcm4chee || true
docker.io build --rm=true -t dcm4chee .
