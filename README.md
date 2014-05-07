docker-dcm4chee
===============

This project builds a [Docker](https://www.docker.io/) image for the [DCM4CHEE](http://www.dcm4che.org/) medical image manager/archive. The Docker image includes DCM4CHEE running on a JBoss webapp server, backed by a MySQL database.  Installing DCM4CHEE is a [non-trivial exercise](http://dcm4che.org/confluence/display/ee2/Installation), so using a pre-built Docker image can save a lot of time.

## Building a running the 'dcm4chee' image

The 'dcm4chee' image can be built as follows:

    docker.io build --rm=true -t dcm4chee .

Once built the 'dcm4chee' image can be run as follows:

    docker.io run -p 8080:8080 -p 11112:11112 --name="pacs" dcm4chee

Note that two ports must be mapped. Port 8080 is used by the DCM4CHEE web UI, while port 11112 is the DICOM port through which PACS workstations can perform DICOM network actions such as searching the archive, and downloading and uploading medical images.

For convenience, shell scripts for the above actions are provided: `build.bash` to build the image, and `run.sh` to run a container based on the image.

## Managing the server

Once a dcm4chee container is running its web UI available at [http://localhost:8080/dcm4chee-web3].

The default Administrator login is "admin", password "admin".  These can be changed in the web UI.

The server's default Application Entity (AE) title is "DCM4CHEE". If you need to chaneg this server's AE title this is done through its JMX management interface at [http://localhost:8080/jmx-console]. Follow the link `service=AE` to the configuration page for the AE service (under the "dcm4chee.archive" heading).  Invoke the operation `updateAETitle()`, specifying the old AE title "DCM4CHEE" and your AE title as parameters.

DICOM communications between two parties, such as a client image viewer app and a DCM4CHEE server, require the AE info of each party to be configured on the other party.  So on your client app you must at least configure the AE title, host name (or IP address), and port number of the DCM4CHEE server, and on the DCM4CHEE server you must at least configure the AE title, host, and port of the client app.

Once you have finished the above you are ready to store DICOM images to your DCM4CHEE server

