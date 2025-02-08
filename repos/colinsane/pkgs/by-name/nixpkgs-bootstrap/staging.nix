{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "746797476c9e43c348bc0b8d2bafa4c65b74e7c4";
  sha256 = "sha256-0eXqAsNHngVQbXgXE7Fpuo3m2fL9u4zZlWkMhNsdhz0=";
  version = "0-unstable-2025-02-07";
  branch = "staging";
}
