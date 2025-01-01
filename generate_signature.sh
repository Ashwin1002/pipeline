#!/bin/bash
echo "Create android key signature and update an key.properties! \n"

# Check if Flutter CLI is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter CLI not found. Please install Flutter and make sure it's added to your PATH."
    exit 1
fi

echo "What is your app desired key name?"
read keyName

echo "What is your app desired key alias?"
read keyAlias

echo "What is your desired password (you'll set this on key generation this is for key. properties file so let them be the same)"
read keyPassword

echo ====================================
echo =========   GENERATING    ==========
echo ====================================

keyPath=$(pwd)"/android"

if keytool -genkey -v -keystore "$keyPath/$keyName.keystore" -alias $keyAlias -keyalg RSA -keysize 2048 -validity 2000000; then
    echo "storePassword=$keyPassword
    keyPassword=$keyPassword
    keyAlias=$keyAlias
    storeFile=../$keyName.keystore" > './android/key.properties'
    echo -e "\n$keyName.keystore" >> .gitignore
    echo "Get your SHA1 and SHA256 from here"
    keytool -list -v -keystore "$keyPath/$keyName.keystore" -alias $keyAlias
    echo "Key generated successfully!"
else
    echo "Error: Failed to generate key. Please check if you have keytool installed.."
    exit 1
fi