{ lib, writeScript, writeScriptBin, bashInteractive }:

# Recommended base packages are [ coreutils gnugrep gnused gawk less ]
{ name, binName ? "env-${name}", packages, bashrc ? "" }:

# TODO: find a less ugly way
# TODO: pass through HOME and TERM
let
  rcfile = writeScript "${name}-rcfile" (''
    IN_NIX_SHELL=pure

    PS1='\n\[\033[1;32m\][${name}-shell:\w]\$\[\033[0m\] ';

  '' + bashrc);
  script = writeScript "${name}-setup" ''
    export PATH=${lib.makeBinPath ([ bashInteractive ] ++ packages)}
    export __ETC_PROFILE_SOURCED=1
    ${bashInteractive}/bin/bash --rcfile ${rcfile}
  '';
in writeScriptBin binName ''
  env -i -S sh -c ${script}
''
