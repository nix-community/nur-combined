{ withSystem, inputs, ... }:
let
  kernelOverlay =
    final: prev:
    let
      master = import inputs.nixpkgs-master {
        inherit (prev.stdenv.hostPlatform) system;
        inherit (prev) config;
      };
    in
    {
      # Keep the kernel and its external modules from the same package set.
      linux_testing = master.linux_latest;
      linuxPackages_testing = master.linuxPackages_latest.extend (
        _kernelFinal: kernelPrev: {
          v4l2loopback = kernelPrev.v4l2loopback.overrideAttrs (old: {
            # Generate depmod indexes only after merging the kernel and external modules.
            makeFlags = (old.makeFlags or [ ]) ++ [ "DEPMOD=true" ];
          });
        }
      );
    };
in
{
  flake.overlays.kernel = kernelOverlay;
  flake.overlays.envoy = final: _prev: {
    envoy = final.callPackage ../pkgs/by-name/envoy-realm.nix { };
  };
  flake.modules.nixos.overlay =
    # Go: https://github.com/NixOS/nixpkgs/issues/86349#issuecomment-624489806
    # Rust:
    {
      nixpkgs.overlays = (
        withSystem "x86_64-linux" (
          { inputs', ... }:
          (map
            (
              i:
              if inputs.${i}.overlays ? "default" then inputs.${i}.overlays.default else inputs.${i}.overlays.${i}
            )
            [
              "fenix"
              "nuenv"
              "dae"
              "niri"
              "nix-cachyos-kernel"
              "run0-sudo-shim"
            ]
          )
          ++ [
            (
              final: prev:
              (prev.lib.genAttrs [
                "prismlauncher"
                "resign"
                "nix-direnv"
                # "radicle"
                "xwayland-satellite"
                # "atuin"
                "vicinae"
              ] (n: inputs'.${n}.packages.default))

              // {
                inherit (inputs'.browser-previews.packages) google-chrome-beta;
                inherit (inputs'.nixpkgs-stable.legacyPackages) calibre-web wayprompt;
                # foot = prev.foot.overrideAttrs (o: {
                #   version = "1.26.0-ecf3";
                #   src = prev.fetchFromCodeberg {
                #     owner = "dnkl";
                #     repo = "foot";
                #     rev = "ecf3b864e461bf6bf5033ac794cc6109013cd816";
                #     hash = "sha256-TbeDUJkdkz8IVAnSnf75gvVhGxwcMOizpSGSHq6rKrM=";
                #   };
                # });
                # telegram-desktop = prev.telegram-desktop.override {
                #   unwrapped = prev.telegram-desktop.unwrapped.overrideAttrs (old: {
                #     patches = (old.patches or [ ]) ++ [ ./tdesktop-focus.patch ];
                #   });
                # };
                # sing-box = prev.sing-box.overrideAttrs (o: {
                #   version = prev.sing-box.version + "-mldsa65";
                #   src = prev.fetchFromGitHub {
                #     owner = "oluceps";
                #     repo = "sing-box";
                #     rev = "a7a37926c8dd0934ea8e9b201913eeaf86b3cc9d";
                #     hash = "sha256-an99ek6YExBpqd9tlyXJO/flLECJbcC9Fl3DgCGra2Q=";
                #   };
                #   vendorHash = "sha256-5ou+KtnnZSPwr+wGhTZADD6rpC53pYi0KAhjHJ3Bqv0=";
                # });
              }
            )
          ]
        )
        ++ [
          inputs.self.overlays.default
          kernelOverlay
          inputs.self.overlays.envoy
          inputs.nix-topology.overlays.default
          inputs.nix-minecraft.overlay
        ]
      );
    };
}
