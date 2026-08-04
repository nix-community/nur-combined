final: prev: {
  eownerdead = prev.lib.concatMapAttrs (
    name: type:
    if type == "directory" then
      { "${name}" = prev.callPackage (./pkgs + "/${name}/package.nix") { }; }
    else
      { }
  ) (builtins.readDir ./pkgs);
}
