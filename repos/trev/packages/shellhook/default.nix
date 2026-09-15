{
  getForgejoFlake,
  system,
}:
(getForgejoFlake {
  url = "https://trev.zip/llc/shellHook";
  rev = "0eedc7ec62041d270349860123e3cfaf4830c871"; # v0.1.1
  hash = "sha256-F+2U8DpSwgJaDO9KC9+8GfQEQpOiCO5TLOsJ4jSnGUg=";
}).packages."${system}".default
