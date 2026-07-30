let
  pkgs = import <nixpkgs> { };
  jps_repo = pkgs.callPackage ./pkgs/applications/editors/jetbrains/source/jps_repo.nix {
    mvnDeps = ./by-name/je/jetbrains_idea-oss/idea_maven_artefacts.json;
  };
in
jps_repo
