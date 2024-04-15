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
          || (type == "regular" && hasSuffix ".nix" name && ! (name == "default.nix") && ! (name == "overlays.nix"))
      )
      (builtins.readDir ./.)));
}
