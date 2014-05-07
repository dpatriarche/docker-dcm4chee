#!/bin/bash
set -v

/usr/bin/mysqld_safe &
/var/local/dcm4chee/dcm4chee-2.17.1-mysql/bin/run.sh
