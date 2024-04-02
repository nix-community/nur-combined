{ withSystem, self, inputs, ... }:
let
  generalHost = [
    # "colour"
    "nodens"
    "kaambl"
    # "abhoth"
    "azasos"
  ];
in
{
  flake = withSystem "x86_64-linux" ({ config, inputs', system, ... }:
    {
      colmena =
        let inherit (self) lib;
        in
        {
          meta = {
            nixpkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                segger-jlink.acceptLicense = true;
                allowUnsupportedSystem = true;
              };
              overlays = (import ../overlays.nix inputs)
              ++
              (lib.genOverlays [
                "self"
                "fenix"
                "nuenv"
                "agenix-rekey"
                "android-nixpkgs"
                "nixpkgs-wayland"
                "berberman"
                "attic"
                "misskey"
              ]);
            };

            nodeNixpkgs = { };

            specialArgs = {
              inherit lib self inputs inputs';
              inherit (config) packages;
              inherit (lib) data;
            };

            nodeSpecialArgs = {
              hastur = { user = "riro"; };
            } // (lib.genAttrs generalHost
              (n: { user = "elen"; }));
          };
        } // (lib.genAttrs (generalHost ++ [ "hastur" ]) (h: ./. + "/${h}"));
    });
}
