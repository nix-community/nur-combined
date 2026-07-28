{
  runCommand,
  bash,
  lib,
  vaculib,
  kanidm_vacuVersion,
  jq,
  coreutils,
  openssh,
  gnugrep,
}:
let
  kanidm = kanidm_vacuVersion;
in
assert kanidm != null;
runCommand "kanidm-admin" { meta.mainProgram = "kanidm-admin"; } ''
  declare pathForScript=${
    lib.escapeShellArg (
      lib.makeBinPath [
        kanidm
        coreutils
        jq
        openssh
        gnugrep
      ]
    )
  }
  mkdir -p $out/bin
  declare outFn="$out/bin/kanidm-admin"

  printf '#!${lib.getExe bash}\nPATH=%q\n#original script follows\n\n' "$pathForScript" >> "$outFn"
  cat ${vaculib.path ./main.sh} >> "$outFn"
  chmod a+x -- "$outFn"
''
