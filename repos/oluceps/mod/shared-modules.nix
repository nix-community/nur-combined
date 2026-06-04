{ inputs, ... }:
{
  flake.modules.nixos.shared-modules = {
    imports =
      map
        (
          let
            m = i: inputs.${i}.nixosModules;
          in
          i: if (m i) ? "default" then (m i).default else (m i).${i}
        )
        [
          "run0-sudo-shim"
          "catppuccin"
          "nix-topology"
          "self"
          "hjem"
        ];
  };
}
