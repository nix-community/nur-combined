{
  config,
  lib,
  ...
}:
with lib; {
  imports = attrValues (mapAttrs'
    (name: type: {
      name = removeSuffix ".nix" name;
      value = ./. + "/${name}";
    })
    (filterAttrs
      (
        name: type:
          (type == "directory" && builtins.pathExists "${toString ./.}/${name}/default.nix")
          || (type == "regular" && lib.hasSuffix ".nix" name && ! (lib.hasSuffix "@.nix" name) && ! (name == "default.nix") && ! (name == "overlays.nix"))
          || (type == "symlink" && lib.hasSuffix ".nix" name && ! (name == "default.nix") && ! (name == "overlays.nix") && ! (name == "common.nix"))
      )
      (builtins.readDir ./.)));
}
