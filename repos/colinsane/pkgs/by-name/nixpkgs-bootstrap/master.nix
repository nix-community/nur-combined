{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "d66e8f8ec44f17f273beb2ddeb323f0405489320";
  sha256 = "sha256-QSlwnmKrAak7nJcH88QRem5gLQgP8DgG3426tVQceRw=";
  version = "0-unstable-2024-11-26";
  branch = "master";
}
