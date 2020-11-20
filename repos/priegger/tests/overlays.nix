import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "overlays";
    nodes =
      let
        priegger-overlays = import ../overlays;
      in
      {
        bees = { pkgs, ... }: {
          nixpkgs.overlays = [
            priegger-overlays.bees
          ];

          environment.systemPackages = [ pkgs.bees ];
        };
        nix_unstable = { pkgs, ... }: {
          nixpkgs.overlays = [
            priegger-overlays.nix-unstable
          ];

          nix = {
            package = pkgs.nixUnstable;
          };
        };
      };

    testScript =
      ''
        nix_unstable.succeed("nix --version | tee /dev/stderr | grep 2.4pre20201118_79aa7d9")

        bees.succeed("beesd --help 2>&1 | tee /dev/stderr | grep 'bees version 0.6.3'")
      '';
  }
)
