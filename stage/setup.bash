#!/bin/sh
set -v

apt-get update
apt-get upgrade -y

# Install dependencies
apt-get install -y curl zip mysql-server openjdk-6-jdk

# Make the dcm4chee home dir
DCM4CHEE_HOME=/var/local/dcm4chee
mkdir -p $DCM4CHEE_HOME
cd $DCM4CHEE_HOME

# Download the binary package for DCM4CHEE
curl -G http://colocrossing.dl.sourceforge.net/project/dcm4che/dcm4chee/2.17.1/dcm4chee-2.17.1-mysql.zip > /stage/dcm4chee-2.17.1-mysql.zip
unzip -q /stage/dcm4chee-2.17.1-mysql.zip
DCM_DIR=$DCM4CHEE_HOME/dcm4chee-2.17.1-mysql

# Download the binary package for JBoss
curl -G http://colocrossing.dl.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA-jdk6.zip > /stage/jboss-4.2.3.GA-jdk6.zip
unzip -q /stage/jboss-4.2.3.GA-jdk6.zip
JBOSS_DIR=$DCM4CHEE_HOME/jboss-4.2.3.GA

# Download the Audit Record Repository (ARR) package
curl -G http://colocrossing.dl.sourceforge.net/project/dcm4che/dcm4chee-arr/3.0.11/dcm4chee-arr-3.0.11-mysql.zip > /stage/dcm4chee-arr-3.0.11-mysql.zip
unzip -q /stage/dcm4chee-arr-3.0.11-mysql.zip
ARR_DIR=$DCM4CHEE_HOME/dcm4chee-arr-3.0.11-mysql

# Copy files from JBoss to dcm4chee
$DCM_DIR/bin/install_jboss.sh jboss-4.2.3.GA > /dev/null

# Copy files from the Audit Record Repository (ARR) to dcm4chee
$DCM_DIR/bin/install_arr.sh dcm4chee-arr-3.0.11-mysql > /dev/null

# Install and set up MySQL
mysql_install_db
/usr/bin/mysqld_safe &
sleep 5s
# Create the 'pacsdb' and 'arrdb' databases, and 'pacs' and 'arr' DB users.
mysql -uroot < /stage/create_dcm4chee_databases.sql
# Load the 'pacsdb' database schema
mysql -upacs -ppacs pacsdb < $DCM_DIR/sql/create.mysql
# The ARR setup script needs to be patched
sed "s/type=/engine=/g" $ARR_DIR/sql/dcm4chee-arr-mysql.ddl > fixed.ddl
mv fixed.ddl $ARR_DIR/sql/dcm4chee-arr-mysql.ddl
# Load the 'arrdb' database schema
mysql -uarr -parr arrdb < $ARR_DIR/sql/dcm4chee-arr-mysql.ddl
killall mysqld
sleep 5s

# Patch the JPEGImageEncoder issue for the WADO service
sed -e "s/value=\"com.sun.media.imageioimpl.plugins.jpeg.CLibJPEGImageWriter\"/value=\"com.sun.image.codec.jpeg.JPEGImageEncoder\"/g" < $DCM_DIR/server/default/conf/xmdesc/dcm4chee-wado-xmbean.xml > dcm4chee-wado-xmbean.xml
mv dcm4chee-wado-xmbean.xml $DCM_DIR/server/default/conf/xmdesc/dcm4chee-wado-xmbean.xml

# Update environment variables
echo "\
JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64\n\
PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\n\
" > /etc/environment
