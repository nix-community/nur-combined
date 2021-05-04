{ pkgs }:
with pkgs.lib;
let
  plugins = fromJSON (fileContents ./plugins.json);
  
  mkSrc = { type, ... }@src:
    if type == "github"
      then fetchFromGitHub src
    else
      builtins.abort "unknown src type ${type}";
  
  mkZshPlugin = name: { src, ... }@args: args // {
    inherit name;
    src = mkSrc src;
  };
in mapAttrs mkZshPlugin plugins