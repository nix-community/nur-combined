{ stdenv, lib, buildFHSUserEnv }:

buildFHSUserEnv {
  name = "fhs-std";
  targetPkgs = pkgs: with pkgs; [
    envsubst exa git gnumake coreutils
  ];
  runScript = "/bin/bash";
}
