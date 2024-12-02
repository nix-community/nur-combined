{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "007b4f3e7125ea24db4e109c95d79895c589dbf4";
  sha256 = "sha256-5evpYZPdl7bDN8z5bRLhYj/wpE36dfm/LieEEzNWt0w=";
  version = "0-unstable-2024-12-01";
  branch = "staging";
}
