#!/bin/sh

set -e
set -x

# Upgrade.
nixos-rebuild switch --upgrade

# Build the Azure VHD
nix-env -i git
git clone https://github.com/nixos/nixpkgs
git checkout release-14.12
cd nixpkgs/nixos/maintainers/scripts/azure
./create-azure.sh

# At this point, VHD to be found on Nix store
# You can extract it with SCP or upload to Azure.

# Example below, but you need azure-cli and jq before proceeding.
# You also need to specify the AZDSK variable pointing to the VHD
# (See other scripts in nixpkgs/nixos/maintainers/scripts/azure)

# You need azure-cli and jq before proceeding.
#AZDSK=
#AZRG=nos99
#AZRS=$AZRG
#AZRL=westus
#azure config mode arm
#azure group create $AZRG $AZRL
#azure storage account create $AZRS --resource-group $AZRG --location $AZRL --type "GRS"
#AZKEY=`azure storage account keys list -g $AZRG $AZRS --json | jq -r`
#azure storage container create -a $AZRS -k $AZKEY vm-images
#azure storage blob upload -t page -a $AZRS -k $AZKEY --container vm-images $AZDSK 
##azure vm create $AZRG my-vm $AZRL Linux -d https://$AZRS.blob.core.windows.net/vm-images/`basename $AZDSK` --admin-username azureuser --nic-name nixNic1 --vnet-name nix-vnet1 --vnet-address-prefix 10.0.0.1/16 --vnet-subnet-name nix-subnet1 --vnet-subnet-address-prefix 10.0.1.1/24 --public-ip-name nix-public-ip --public-ip-domain-name nix-public-ip-domain

# Cleanup any previous generations and delete old packages.
nix-collect-garbage -d

#################
# General cleanup
#################

# Clear history
unset HISTFILE
if [ -f /root/.bash_history ]; then
  rm /root/.bash_history
fi
if [ -f /home/vagrant/.bash_history ]; then
  rm /home/vagrant/.bash_history
fi

# Clear temporary folder
rm -rf /tmp/*

# Truncate the logs.
#find /var/log -type f | while read f; do echo -ne '' > $f; done;

# Zero the unused space.
#count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`
#let count--
#dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
#rm /tmp/whitespace;
