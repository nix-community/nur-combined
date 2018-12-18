{ lib, runCommand, wrapper }:

with lib;

let
  wrapperPath = "${wrapper}/bin/xf-${wrapper.name}";
  mkAliases = let
    mkAlias = cmd: ''
      ln -s ${wrapperPath} $out/bin/${cmd}
    '';
  in concatMapStrings mkAlias;

in runCommand "${wrapper.name}-aliases" {} ''
  mkdir -p $out/bin
  ${mkAliases [ "plan" "apply" "destroy" "terraform" ]}
''
