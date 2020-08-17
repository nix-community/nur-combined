{ lib, writeScript, writeScriptBin, bashInteractive }:

# Recommended base packages are [ coreutils gnugrep gnused gawk ]
{ name, packages }:

# TODO: find a less ugly way
# TODO: pass through HOME and TERM
let
  script = writeScript "${name}-setup" ''
    export PATH=${lib.makeBinPath ([ bashInteractive ] ++ packages)}
    export __ETC_PROFILE_SOURCED=1
    export IN_NIX_SHELL=pure

    # TODO: Use custom rc file like nix-shell
    export PS1='\n\[\033[1;32m\][${name}-shell:\w]\$\[\033[0m\] ';

    bash --norc
  '';
in writeScriptBin name ''
  env -i -S sh -c ${script}
''
