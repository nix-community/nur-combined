{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "3e2f14db3470a148d8bab9f3ae9902c0f8724572";
  sha256 = "sha256-QhBpIP0wbUIEdW5DCBg5CrIEzV29bZZpGOVMEvAf/YQ=";
  version = "0-unstable-2024-12-10";
  branch = "staging";
}
