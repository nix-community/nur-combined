{ ci }: let
  pkgs = import <nixpkgs> { };
in {
  # https://github.com/arcnmx/ci
  channels = {
    nixpkgs = "unstable";
    home-manager = "master";
    mozilla = "master";
  } // ci.channelsFromEnv ci.screamingSnakeCase "NIX_CHANNELS_";

  allowRoot = (builtins.getEnv "CI_ALLOW_ROOT") != "";
  closeStdin = (builtins.getEnv "CI_CLOSE_STDIN") != "";

  #glibcLocales = [ pkgs.glibcLocales ];

  cache.cachix = {
    arc = { };
  };
}
