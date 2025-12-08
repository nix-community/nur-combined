{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "9294dce300c448a10cff678f78d5f958ad7b5e77";
  sha256 = "sha256-Rbm89fbJQim4foRljfCgfT+P0LvPudChtwjsLU+bzXU=";
  version = "unstable-2025-12-08";
  branch = "staging-next";
}
