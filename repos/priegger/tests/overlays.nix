import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "overlays";
    nodes = {
      nix_unstable = { pkgs, ... }:
        let
          priegger-overlays = import ../overlays;
        in
        {
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
        nix_unstable.wait_for_unit("multi-user.target")
        nix_unstable.succeed("nix --version | tee /dev/stderr | grep 2.4pre20201119_79aa7d9")
      '';
  }
)
