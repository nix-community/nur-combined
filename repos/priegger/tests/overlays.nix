import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "overlays";
    nodes = {
      nix_unstable =
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
        nix_unstable.succeed("nix --version | tee /dev/stderr | grep 3.0pre20200829_f156513")
      '';
  }
)
