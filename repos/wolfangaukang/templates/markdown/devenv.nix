{ pkgs
, ...
}:

let
  inherit (pkgs) dprint;

in {
  packages = [
    dprint
  ];
}
