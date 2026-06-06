{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "fc86b622ca4dbb08c5dffb8ea95a4cbd92b0720c";
  sha256 = "sha256-Xqyn31qpwNWxkP4JgEVWGwIdB6MK1mc6+jDkrWrU98E=";
  version = "unstable-2026-06-06";
  branch = "staging";
}
