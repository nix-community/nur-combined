{ name, config, pkgs }:
let
  inherit (pkgs) lib stdenv;
  inherit (lib.strings) hasInfix;
  sshKeys = with builtins;
    if (hasAttr "secrets" config.age) then
      (filter (x: hasInfix "${name}-id-ed25519" x.name)
        (attrValues config.age.secrets))
    else
      [ ];
in sshKeys
