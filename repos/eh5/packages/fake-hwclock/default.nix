{
  lib,
  writeShellScriptBin,
  coreutils,
}:
writeShellScriptBin "fake-hwclock" ''
  export PATH="$PATH''${PATH:+:}${coreutils}/bin"
  ${builtins.readFile ./fake-hwclock.sh}
''
// {
  meta = {
    description = "Fake hardware clock";
    license = lib.licenses.gpl3;
  };
}
