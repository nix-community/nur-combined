{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "4c90bb551c13f308a9798f0f0d5f1fa2bbf6e2df";
  sha256 = "sha256-3ySlbOSAjeNchnptCxn8SEAAkflltInMwKgdQZti9uQ=";
  version = "0-unstable-2024-12-17";
  branch = "staging-next";
}
