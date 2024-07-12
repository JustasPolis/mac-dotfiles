#!/bin/bash

# Define the URL of the zip file to download
URL="https://github.com/johnno1962/InjectionIII/releases/download/5.0.0/InjectionIII.app.zip"

# Define the temporary directory where the zip file will be downloaded
TMP_DIR="/tmp"

# Download the zip file using curl
curl -L -o "$TMP_DIR/InjectionIII.app.zip" "$URL"

# Unzip the downloaded file
unzip "$TMP_DIR/InjectionIII.app.zip" -d "$TMP_DIR"

# Move the application to /Applications
mv "$TMP_DIR/InjectionIII.app" /Applications/

# Remove the zip file from the temporary directory
rm "$TMP_DIR/InjectionIII.app.zip"

echo "InjectionIII.app has been downloaded, unzipped, moved to /Applications, and the zip file has been deleted."
