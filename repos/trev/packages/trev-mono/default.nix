{
  getForgejoFlake,
  system,
}:
(getForgejoFlake {
  url = "https://trev.zip/llc/trev-mono";
  rev = "4996fec05f413195c8afa2353f8dc22d9ebef757"; # v0.2.6
  hash = "sha256-ovoWYVKlah0RwZjMkOS1ecFZ3eI5bPyvUDpshzofFsM=";
}).packages."${system}".default
