{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "0de86d8d8fc590f1c19ab7fee72fc395b71bf246";
  sha256 = "sha256-UN1kx9WMuDSWRI7H9HwHP0ODzVmct+1wGxoGfNzyLH4=";
  version = "0-unstable-2024-12-09";
  branch = "staging-next";
}
