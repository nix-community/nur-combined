{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "89af367cd45fe25a2b1fab546dd5733410783da2";
  sha256 = "sha256-4yXQe+73NBCa41OrIik3H2mUBcpHivpkAe/bi0if9Es=";
  version = "unstable-2026-09-03";
  branch = "staging-next";
}
