#!/usr/bin/env bash

echo "🧹 Starting Nix cleanup..."

echo "🗑️  Collecting user garbage..."
nix-collect-garbage -d

echo "🖥️  Collecting system garbage..."
sudo nix-collect-garbage -d

echo "⚡ Optimising the Nix store (this may take a while)..."
nix-store --optimise

echo "✅ Cleanup complete!"
