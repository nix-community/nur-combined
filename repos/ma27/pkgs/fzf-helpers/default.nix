{ runCommand }:

runCommand "fzf-nix-helpers" { } ''
  mkdir -p $out/bin
  cp ${./nix-package-wrapper.sh} $out/bin/nix-package-wrapper
  cp ${./nixos-option-wrapper.sh} $out/bin/nixos-option-wrapper
  patchShebangs $out/bin
''
