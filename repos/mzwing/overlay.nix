# Expose repository packages without the full NUR namespace.
self: super: let
  isReserved = n: n == "lib" || n == "overlays" || n == "nixosModules" || n == "homeModules" || n == "darwinModules" || n == "flakeModules";
  nameValuePair = n: v: {
    name = n;
    value = v;
  };
  nurAttrs = import ./default.nix {pkgs = super;};
in
  builtins.listToAttrs
  (map (n: nameValuePair n nurAttrs.${n})
    (builtins.filter (n: !isReserved n)
      (builtins.attrNames nurAttrs)))
