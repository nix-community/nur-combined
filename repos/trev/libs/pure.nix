{
  systems ? [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
  ],
}:
{
  mkFlake = import ./mkFlake { inherit systems; };
}
