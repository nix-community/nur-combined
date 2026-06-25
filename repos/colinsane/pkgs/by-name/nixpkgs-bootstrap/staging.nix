{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4516515e07e711a563695d7a9265a79c8f9d7a33";
  sha256 = "sha256-ecbZGjOOYXKDUljjnAZfeMnQ6BPYcckEQTRzBVsqXNU=";
  version = "unstable-2026-06-25";
  branch = "staging";
}
