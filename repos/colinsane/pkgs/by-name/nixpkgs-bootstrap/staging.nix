{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "6d0f6703f7555b368934325132073ef9a9bf7179";
  sha256 = "sha256-vuK0axOBDPdXOfw/qIiFCP/nX30eq0sUgR2zwcuUtvY=";
  version = "0-unstable-2024-11-26";
  branch = "staging";
}
