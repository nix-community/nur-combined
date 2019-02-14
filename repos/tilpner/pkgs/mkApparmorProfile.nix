{ stdenvNoCC, lib, writeText, closureInfo }: with lib;

{ subject,
  name ? "${subject.name}.profile",
  runtimeDeps ? [ subject ],
  enforce ? true,
  rlimit ? {},
  signalReceive ? true,
  prepend ? [],
  append ? [] }:

let
  flags = if enforce then "" else "flags=(complain)";

  closurePaths = path:
    let closure = closureInfo { rootPaths = path; };
        text = lib.fileContents "${closure}/store-paths";
    in lib.splitString "\n" text;

  rules = [
    prepend
    "@{PROC}/@{pid}/** r"
    "@{PROC}/sys/vm/overcommit_memory r"
    "/sys/kernel/mm/transparent_hugepage/enabled r"
    (optional signalReceive "signal (receive)")
    (mapAttrsToList
      (k: v: "set rlimit ${k} <= ${toString v}")
      rlimit)
    (map (p: "${p}** mkrix") (closurePaths runtimeDeps))
    append
  ];

  lines = [
    "include <tunables/global>"
    "${lib.getBin subject}/bin/* ${flags} {"
      (map (r: "  ${r},") (flatten rules))
    "}"
  ];
in writeText name (concatStringsSep "\n" (flatten lines))
