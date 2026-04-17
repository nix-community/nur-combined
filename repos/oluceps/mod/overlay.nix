{ withSystem, inputs, ... }:
{
  flake.modules.nixos.overlay =
    # Go: https://github.com/NixOS/nixpkgs/issues/86349#issuecomment-624489806
    # Rust:
    {
      nixpkgs.overlays = (
        withSystem "x86_64-linux" (
          { inputs', ... }:
          (map (i: inputs.${i}.overlays.default or inputs.${i}.overlays.${i}) [
            "fenix"
            "nuenv"
            "dae"
            "niri"
            "nix-cachyos-kernel"
            "run0-sudo-shim"
          ])
          ++ [
            (
              final: prev:
              prev.lib.genAttrs [
                "prismlauncher"
                "resign"
                "nix-direnv"
                # "radicle"
                "xwayland-satellite"
                "atuin"
                "vicinae"
              ] (n: inputs'.${n}.packages.default)

              // {
                inherit (inputs'.browser-previews.packages) google-chrome-beta;
                inherit (inputs'.nixpkgs-stable.legacyPackages) calibre-web;
                foot = prev.foot.overrideAttrs (o: {
                  version = "1.26.0-ecf3";
                  src = prev.fetchFromCodeberg {
                    owner = "dnkl";
                    repo = "foot";
                    rev = "ecf3b864e461bf6bf5033ac794cc6109013cd816";
                    hash = "sha256-TbeDUJkdkz8IVAnSnf75gvVhGxwcMOizpSGSHq6rKrM=";
                  };
                });
              }
            )
          ]
        )
        ++ [
          inputs.self.overlays.default
          inputs.nix-topology.overlays.default
        ]
      );
    };
}
