#!/usr/bin/env bash
set -e

echo "Ensuring matchbox_server is installed..."
cargo install matchbox_server || true

echo "Starting Matchbox signaling server..."
~/.cargo/bin/matchbox_server &
MATCHBOX_PID=$!
echo "Building Hanga engine..."
nix build .#hanga

echo "Starting Client 1 (Headless)..."
nix run nixpkgs#xvfb-run -- -a ./result/bin/hanga --headless &
CLIENT1_PID=$!

echo "Starting Client 2 (Agent Client / Headless)..."
nix run nixpkgs#xvfb-run -- -a ./result/bin/hanga --agent-client &
CLIENT2_PID=$!

echo "Waiting for clients to connect and establish P2P WebRTC..."
sleep 15

echo "Stopping clients and signaling server..."
kill -SIGINT $CLIENT1_PID || true
kill -SIGINT $CLIENT2_PID || true
kill -SIGTERM $MATCHBOX_PID || true

echo "Multiplayer WebRTC test complete!"
