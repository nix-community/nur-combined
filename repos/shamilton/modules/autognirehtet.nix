{ autognirehtet }:
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.autognirehtet;
  nixpkgsAndroidtools = import (builtins.fetchTarball {
    url = "http://github.com/NixOS/nixpkgs/archive/6120ab426d8d652ff9d42caf1abc4e268af0bcb1.tar.gz";
    sha256 = "159rq171wdglcjxbbdsn642sgcgza7spzzfdvk5any5c3gwak7yr";
  }) {};
  version = "2.5";
  apk = with pkgs; stdenv.mkDerivation {
    pname = "gnirehtet.apk";
    inherit version;
    src = fetchzip {
      url = "https://github.com/Genymobile/gnirehtet/releases/download/v${version}/gnirehtet-rust-linux64-v${version}.zip";
      sha256 = "1db0gkg5z8lighhkyqfsr9jiacrck89zmfnmp74vj865hhxgjzgq";
    };
    installPhase = ''
      mkdir $out
      mv gnirehtet.apk $out
    '';
  };
  gnirehtetNoAndroidenv = pkgs.gnirehtet.overrideAttrs (old: {
    postInstall = ''
      wrapProgram $out/bin/gnirehtet \
      --set GNIREHTET_APK ${apk}/gnirehtet.apk
    '';
  });
in
{
  options.services.autognirehtet = {
    enable = mkEnableOption "AutoGnirehtet, reverse thetering to your android device";
  };
  config = mkIf cfg.enable {
    systemd.services.autognirehtet = {
      path = with nixpkgsAndroidtools; [
        android-tools
        gnirehtetNoAndroidenv
      ];
      description = "AutoGnirehtet, reverse thetering to your android device";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = [ "${autognirehtet}/bin/auto-gnirehtet" ];
      };
    };
  };
}
