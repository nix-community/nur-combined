#!/bin/bash

echo "Cloning the nvidia-all repository..."
rm -rf ~/Downloads/nvidia-all
git clone https://github.com/Frogging-Family/nvidia-all.git ~/Downloads/nvidia-all --depth 1
cd ~/Downloads/nvidia-all || exit

echo "Check current version of nvidia driver..."
nvidia-smi

echo "Run nvidia-all package..."
makepkg -si

echo "Cleaning up..."
cd ~ || exit
rm -rf ~/Downloads/nvidia-all
