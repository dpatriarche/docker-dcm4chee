#!/bin/bash
set -v

docker.io run -p 8080:8080 -p 11112:11112 -i -t --name="pacs_shell" dcm4chee /bin/bash
