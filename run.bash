#!/bin/bash
set -v

docker.io run -p 8080:8080 -p 11112:11112 --name="pacs" dcm4chee
