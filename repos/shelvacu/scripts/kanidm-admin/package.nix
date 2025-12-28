{
  runCommand,
  kanidm_1_8 ? null,
  coreutils,
  bash,
  lib,
  vaculib,
  whichKanidm ? null,
}:
let
  kanidm = if whichKanidm != null then whichKanidm else kanidm_1_8;
in
assert kanidm != null;
runCommand "kanidm-admin" {
  meta.mainProgram = "kanidm-admin";
} ''
  declare pathForScript=${lib.escapeShellArg (lib.makeBinPath [ kanidm coreutils ])}
  mkdir -p $out/bin
  declare outFn="$out/bin/kanidm-admin"

  printf '#!${lib.getExe bash}\nPATH=%q\n#original script follows\n\n' "$pathForScript" >> "$outFn"
  <${vaculib.path ./main.sh} >> "$outFn"
  chmod a+x -- "$outFn"
''
