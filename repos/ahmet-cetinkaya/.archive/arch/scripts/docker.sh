#!/bin/bash

# Install Docker
sudo pacman -Syu --noconfirm docker

# Enable and start Docker service
sudo systemctl enable --now docker.service

# Add user to Docker group
sudo usermod -aG docker "$USER"

echo "Docker installed. Log out and back in to apply group changes."
