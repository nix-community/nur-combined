{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "3a274436ba6971de4bded7f7b6a038b1a714bd03";
  sha256 = "sha256-5ODnpwstY6Xeg097eyvAbqnvjSw8HMbzEGT/NeyxQGI=";
  version = "unstable-2026-10-10";
  branch = "staging-next";
}
