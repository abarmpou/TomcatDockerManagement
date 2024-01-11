# Tomcat Docker Management
A collection of bash scripts for creating, and maintaining a tomcat web application using docker.
Tested in Ubuntu 22.04.

### Prerequisite

The only prerequisite is `default-jdk` which can be installed by:
```
apt update
apt install default-jdk
```

## How to create a tomcat docker web application

In the terminal type: `./create_tomcat.sh name`

This will create a docker tomcat container `name_tomcat` and will make the app accessible at `http://localhost:8201/`.

If you want to create the app in a specific port: `./create_tomcat.sh -p 81 name`

This will create a docker tomcat container `name_tomcat` and will make the app accessible at `http://localhost:81/`.

The tomcat logs are saved at the folder: `name/logs`
The tomcat webapps can be placed at the folder: `name/webapps`
If you create a folder: `name/app` that contains a `.war` file, it will be automatically copied to the `name/webapps` folder as `ROOT.war` and will be deployed as the root application.
Optionally, if the `name/app` folder contains the file `WEB-INF/web.xml` it will be copied inside the `.war` file before is deplayed as `ROOT.war`.

## How to delete a tomcat docker web application

In the terminal type: `./remove_tomcat.sh name`

This will stop and remove the container `name_tomcat`. If you also want to remove the files from your local drive type: `rm -r name`.

