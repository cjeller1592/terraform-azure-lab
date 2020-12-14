#!/bin/bash

terraform init

echo "Creating the lab ..."

terraform apply --auto-approve

echo "Creating the private key for Kali box ..."

# Feel free to change the directory of your private key 

terraform output tls_private_key > lab1.pem && sudo chmod 400 lab1.pem

# Change the username to what you added to terraform file 

echo "Logging into the Kali box ..."

ssh -i lab1.pem changemyname@$(terraform output kali_ip)