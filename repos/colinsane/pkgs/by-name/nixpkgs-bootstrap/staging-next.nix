{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "d8008c052d97567b78ea3dfe1031e3944343f327";
  sha256 = "sha256-QhBpIP0wbUIEdW5DCBg5CrIEzV29bZZpGOVMEvAf/YQ=";
  version = "0-unstable-2024-12-10";
  branch = "staging-next";
}
