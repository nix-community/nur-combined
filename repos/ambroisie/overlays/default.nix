# Automatically import all overlays in the directory
let
  files = builtins.readDir ./.;
  overlays = removeAttrs files [ "default.nix" ];
in
builtins.mapAttrs (name: _: import "${./.}/${name}") overlays
