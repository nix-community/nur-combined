{ pkgs }:
with pkgs;
rec {
  nodeEnv = import ./node-env.nix;

  fetchedGithub = path:
    let
      json = lib.importJSON path;
    in rec {
      version = json.tag;
      pname = json.meta.name;
      name = "${pname}-${version}";
      src = fetchFromGitHub json.github;
    };

  fetchedGit = path:
    let
      json = lib.importJSON path;
    in rec {
      version = json.tag;
      pname = json.meta.name;
      name = "${pname}-${version}";
      src = fetchgit json.git;
    };

  fetchedGitPrivate = path:
    let
      json = lib.importJSON path;
    in rec {
      version = json.tag;
      pname = json.meta.name;
      name = "${pname}-${version}";
      src = builtins.fetchGit {
        url = json.git.url;
        ref = "master";
        rev = json.git.rev;
      };
    };
} // (if builtins.pathExists ./private then callPackage ./private {} else {})
