{
  getForgejoFlake,
  system,
}:
(getForgejoFlake {
  url = "https://trev.zip/llc/trev-mono";
  rev = "1f63c59eed00f9cf6327c80bd9d89e75ad6c60d7"; # v0.2.5
  hash = "sha256-i6vLGIrZrH9YiFS4UNnJBLOI6sjLANqn1LkEbjGu4M0=";
}).packages."${system}".default
