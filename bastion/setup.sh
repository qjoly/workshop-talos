#!/bin/bash

set -e

echo "----------------------"
echo "Installing Talosctl..."
curl -sL https://talos.dev/install | sh
echo "----------------------"
echo "Installing TalHelper..."
curl https://i.jpillora.com/budimanjojo/talhelper! | sudo bash
echo "----------------------"
echo "Installing OpenTofu..."
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
rm -f install-opentofu.sh
echo "----------------------"
echo "Creating users..."
for i in {1..20}; do
  username="user-$i"
  if id "$username" &>/dev/null; then
    echo "User $username already exists, skipping..."
  else
    useradd -m -s /bin/bash "$username"
    echo "$username:talos12345!" | chpasswd
    echo "Created user: $username"
  fi
done
echo "----------------------"

