{fetchFromGitLab}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  fetchFromGitLab {
    owner = "kreativekorp";
    repo = "open-relay";
    inherit (source) rev sha256;
  }
