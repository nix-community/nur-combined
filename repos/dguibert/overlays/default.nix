{
  lib,
  inputs ? null,
  ...
}:
with lib;
  mapAttrs'
  (name: type: {
    name = removeSuffix ".nix" name;
    value = let
      file = ./. + "/${name}";
    in (final: prev:
      import file final (
        prev
        // {
          inherit inputs;
        }
      ));
  })
  (filterAttrs
    (
      name: type:
        (type == "directory" && builtins.pathExists "${toString ./.}/${name}/default.nix")
        || (type == "regular" && hasSuffix ".nix" name && ! (name == "default.nix") && ! (name == "overlays.nix"))
        || (type == "symlink" && hasSuffix ".nix" name && ! (name == "default.nix") && ! (name == "overlays.nix"))
    )
    (builtins.readDir ./.))
