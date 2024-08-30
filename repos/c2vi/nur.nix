# This is the file for my NUR Repo
# Reminder for myself: Any package here should not import <nixpkgs>, but use the pkgs

{ pkgs ? import <nixpkgs> { } }:

let
  lib = pkgs.lib;
  files = builtins.readDir ./mods/nurPkgs;
  names = pkgs.lib.attrsets.mapAttrsToList (name: value: pkgs.lib.strings.removeSuffix ".nix" name) files;
  pwd = builtins.toString ./.;
in pkgs.lib.attrsets.genAttrs names (name: (pkgs.callPackage "${pwd}/mods/nurPkgs/${name}.nix" {}))
//
{

  imap-backup = pkgs.callPackage ./mods/imap-backup/package.nix {};

  /* fails for nur evaluations
  iio-hyprland = let
    repo = pkgs.fetchFromGitHub {
      owner = "yassineibr";
      repo = "iio-hyprland";
      rev = "nix-support";
      hash = "sha256-xFc8J8tlw6i+FbTC05nrlvQIXRmguFzDqh+SQOR54TE=";
    }; in pkgs.callPackage "${repo}/default.nix" {};
    */

  csv2vcf = let 
    src = pkgs.fetchFromGitHub {
      repo = "csv2vcf";
      owner = "mridah";
      rev = "a6e04999f9cfe350cf59107ea8fc17dad1e43bca";
      hash = "sha256-WrlHVQggfU6y7EGLhGR1k5bDyRLp7FUGRdN/8QK9C+o=";
    };
  in pkgs.writeShellApplication {
    name = "csv2vcf"; 
    text = ''
      ${pkgs.python3}/bin/python ${src}/csv2vcf.py "$@"
    '';
    meta = with pkgs.lib; {
      description = "A small command line tool to convert CSV files to VCard (.vcf) files.";
      longDescription = ''
        see repo's README.md
      '';
      homepage = "https://github.com/mridah/csv2vcf";
      license = licenses.mit;
      maintainers = with lib.maintainers; [ ];
      platforms = platforms.all;
    };
  };

}
