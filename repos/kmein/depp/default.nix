{ lib, writeShellScriptBin }:
let
  aliasFlag = name: value: "-c alias.${name}=${lib.escapeShellArg value}";
  aliases = {
    eroeffne = "init";
    machnach = "clone";
    zieh = "pull";
    fueghinzu = "add";
    drueck = "push";
    pfusch = "push --force";
    zweig = "branch";
    verzweige = "branch";
    uebergib = "commit";
    erde = "rebase";
    unterscheide = "diff";
    vereinige = "merge";
    bunkere = "stash";
    markiere = "tag";
    nimm = "checkout";
    tagebuch = "log";
    zustand = "status";
  };
in writeShellScriptBin "depp" ''
  if [ $# -gt 0 ]; then
    git ${lib.concatStringsSep " " (lib.attrsets.mapAttrsToList aliasFlag aliases)} "$@"
  else
    printf "${lib.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (n: v: n + " " + v) aliases)}\n"
  fi
''
