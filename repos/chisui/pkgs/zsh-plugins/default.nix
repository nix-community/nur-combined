{ pkgs }:
with pkgs;
with lib;
with builtins;
let
  plugins = fromJSON (fileContents ./plugins.json);
  
  fetchFromGist = { owner, gist, rev, sha256, name, ...}: fetchgit {
    inherit rev sha256 name;
    url = "https://gist.github.com/${owner}/${gist}";
  };

  mkSrc = { type, ... }@src:
    if type == "github"
      then fetchFromGitHub (filterAttrs (n: v: n != "type") src)
    else if type == "gist"
      then fetchFromGist src
    else
      abort "unknown src type ${type}";
  
  mkZshPlugin = name: { src, ... }@args: args // {
    inherit name;
    src = mkSrc ({ inherit name; } // src);
  };
in mapAttrs mkZshPlugin plugins