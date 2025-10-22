let
  filterAttrs =
    pred: set:
    builtins.removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));
  path = ./.;
in
filterAttrs (n: v: builtins.pathExists v) (
  builtins.mapAttrs (n: v: path + "/${n}/default.nix") (
    filterAttrs (n: v: v == "directory") (builtins.readDir path)
  )
)
