{ pkgs, lib, runCommand } :

with lib;

# Generates benchmark set, based on user config
{ config } :
    let
      cfg = (evalModules {
        modules = [ ./module.nix config ];
        args = { inherit pkgs lib; };
      }).config;

      benchSet = cfg._out;
      pathList = lib.mapAttrsToList (n: v: "${v}") benchSet;
      nameList = lib.mapAttrsToList (n: v: n) benchSet;
    in runCommand "benchset" {} ''
      mkdir -p $out
      ${optionalString cfg.slurm "touch $out/isSlurm"}

      paths=(${concatStringsSep " " pathList})
      names=(${concatStringsSep " " nameList})

      for i in {0..${toString (builtins.length nameList - 1)}}; do
        echo "$i ''${names[$i]} ''${paths[$i]}"
        ln -s ''${paths[$i]} $out/bench-''${names[$i]}
      done

      echo "${cfg.label}" > $out/label
    ''

