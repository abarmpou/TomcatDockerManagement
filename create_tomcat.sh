#!/bin/bash

# Process command-line options
while getopts "p:" opt; do
    case $opt in
        p) port="$OPTARG";;
        *) echo "Invalid option"; exit 1;;
    esac
done

shift $((OPTIND - 1))

# Check if site_name is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide the site_name as an argument."
    exit 1
fi

site_name="$1"

# Check if url_option is not empty
if [ -n "$port" ]; then
    echo "port: $port"
else
    port=8201
    port_found=false

    while [ "$port_found" = false ] && [ "$port" -lt 8300 ]; do
         if docker ps | grep ":$port" >/dev/null; then
            port=$((port + 1))
         else
            port_found=true
         fi
    done

    if [ "$port_found" = false ]; then
       echo "No available ports found in the range."
    else
       echo "Available port: $port"
    fi
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing docker..."
    apt-get update
    apt-get install docker
    apt install docker.io
    docker --version
fi

# Define the image name
image_name="tomcat"

# Check if the Docker image exists
if docker images "$image_name" | grep "$image_name" >/dev/null; then
    echo "The Docker image '$image_name' exists."
else
    echo "The Docker image '$image_name' does not exist. Pulling image..."
    docker pull "$image_name":9.0
fi

# Check if a local folder with the site_name exists
if [ -d "$site_name" ]; then
    echo "A local folder with the name '$site_name' exists."
else
    echo "Creating local folder '$site_name'..."
    mkdir -p "$site_name"/{webapps,database,logs}
fi

if [ -d "$site_name"/app ]; then
   echo "app folder found"

   first_war_file=$(find "$site_name"/app -maxdepth 1 -type f -name "*.war" -print -quit)

   if [ -n "$first_war_file" ]; then
      echo "Found war file: $first_war_file"

      if [ -n "$site_name"/app/WEB-INF/web.xml ]; then
          echo "Found web.xml"
          cd "$site_name"/app
	  jar -uf *.war WEB-INF/web.xml
	  cd ..
	  cd ..
      fi

      echo "Deploying war as ROOT.war"
      rm -r "$site_name"/webapps/ROOT
      cp "$first_war_file" "$site_name"/webapps/ROOT.war
   fi
fi

#chown -R root:root "$site_name"

current_directory=$(pwd)


docker run -p "$port":8080 -v "$current_directory"/"$site_name"/webapps:/usr/local/tomcat/webapps -v "$current_directory"/"$site_name"/database:/data -v "$current_directory"/"$site_name"/logs:/usr/local/tomcat/logs --name "$site_name"_tomcat -d --restart unless-stopped tomcat:9.0

echo "Verify deployed app at: http://localhost:$port/"

