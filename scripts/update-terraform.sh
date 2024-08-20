#!/bin/bash

cd ~
wget https://releases.hashicorp.com/terraform/1.7.4/terraform_1.7.4_linux_amd64.zip
unzip  ~/terraform_1.7.4_linux_amd64.zip -d  ~/terraform_1.7.4_linux_amd64
sudo mv ~/terraform_1.7.4_linux_amd64/terraform /usr/local/bin/