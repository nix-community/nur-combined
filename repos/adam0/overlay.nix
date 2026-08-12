# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.
_self: super: let
  inherit
    (builtins)
    # keep-sorted start
    attrNames
    filter
    listToAttrs
    # keep-sorted end
    ;

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  nameValuePair = n: v: {
    name = n;
    value = v;
  };
  nurAttrs = import ./default.nix {pkgs = super;};
in
  listToAttrs (
    map (n: nameValuePair n nurAttrs.${n}) (
      filter (n: !isReserved n) (attrNames nurAttrs)
    )
  )
