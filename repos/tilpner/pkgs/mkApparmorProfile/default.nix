{ stdenvNoCC, lib, buildPackages }: with lib;

{ subject,
  name ? "${subject.name}.profile",
  runtimeDeps ? [],
  enforce ? true,
  rlimit ? {},
  signalReceive ? true,
  prepend ? [],
  append ? [] }:

let
  prependRules = indent [
    (map (s: "${s},") prepend)
    "@{PROC}/@{pid}/** r,"
    "@{PROC}/sys/vm/overcommit_memory r,"
    "/sys/kernel/mm/transparent_hugepage/enabled r,"
    (optional signalReceive "signal (receive),")
    (mapAttrsToList
      (k: v: "set rlimit ${k} <= ${toString v},")
      rlimit)
  ];

  appendRules = indent [
    (map (s: "${s},") append)
  ];

  indent = lines: map (s: "  ${s}") (flatten lines);
  format = lines: concatMapStrings (s: "${s}\n") (flatten lines);

in stdenvNoCC.mkDerivation {
  inherit name;

  __structuredAttrs = true;
  exportReferencesGraph.closure = [ subject ] ++ runtimeDeps;

  profileArgs = {
    inherit subject enforce;
    name = baseNameOf subject.outPath;
    prepend = format prependRules;
    append = format appendRules;
  };

  PATH = "${buildPackages.python3}/bin";
  builder = builtins.toFile "builder" ''
    . .attrs.sh
    python3 ${./generate.py}
  '';
}
