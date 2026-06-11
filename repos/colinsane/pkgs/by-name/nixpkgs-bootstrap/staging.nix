{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "d79bba9a914e3039123d7d9591cb150ad1c732c7";
  sha256 = "sha256-Q751yZ/Ub0ilq+E24cvfkNFYX3JAgl9hdmSeu4pzi9I=";
  version = "unstable-2026-06-11";
  branch = "staging";
}
