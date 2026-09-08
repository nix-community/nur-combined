{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0b5ad00e26476b7a0564a8e94436b235bc36b1c9";
  sha256 = "sha256-DJ1ETe1ulI8zGPkQk1VsCxGayl3Tw7wrPErhDjqqrHQ=";
  version = "unstable-2026-09-07";
  branch = "staging-next";
}
