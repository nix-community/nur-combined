{ stdenv, lib, buildFHSUserEnv }:

buildFHSUserEnv {
  name = "fhs-std";
  targetPkgs = pkgs: with pkgs; [
    envsubst
    # exa # TODO: switch to eza in 2024
    git
    gnumake
    coreutils
    zsh
  ];
  runScript = "/bin/zsh";
}
