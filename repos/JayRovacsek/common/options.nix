{ self }:
let inherit (self.common) package-sets;
in builtins.mapAttrs (package-set: _:
  let
    pkgs = self.common.package-sets.${package-set};
    inherit (pkgs.stdenv) isLinux isDarwin;
    generic = [ ../options/flake ../options/hardware ../options/networking ];
    linux =
      if isLinux then [ ../options/systemd ../options/tailscale ] else [ ];
    darwin = if isDarwin then [ ../options/blocky ../options/docker ] else [ ];
    imports = generic ++ linux ++ darwin;
  in { inherit imports; }) package-sets
