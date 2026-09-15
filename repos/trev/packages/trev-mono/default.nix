{ system }:
(builtins.getFlake
  "https://trev.zip/llc/trev-mono/archive/1f63c59eed00f9cf6327c80bd9d89e75ad6c60d7.tar.gz?narHash=sha256-i6vLGIrZrH9YiFS4UNnJBLOI6sjLANqn1LkEbjGu4M0%3D" # v0.2.5
).packages."${system}".default
