{ inputs, ... }:
{
  flake.modules.nixos.shared-modules = {
    imports =
      map
        (
          let
            m = i: inputs.${i}.nixosModules;
          in
          i: (m i).default or (m i).${i}
        )
        [
          "run0-sudo-shim"
          "catppuccin"
          "nix-topology"
          "self"
        ];
  };
}
