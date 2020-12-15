import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "overlays";
    nodes =
      let
        priegger-overlays = import ../overlays;
      in
      {
        default = { pkgs, ... }: {
          nixpkgs.overlays = builtins.attrValues priegger-overlays;

          environment.systemPackages = with pkgs; [
            bees
            deno
            prometheus-nginx-exporter
          ];

          nix = {
            package = pkgs.nixUnstable;
          };
        };
      };

    testScript =
      ''
        default.succeed("beesd --help 2>&1 | tee /dev/stderr | grep 'bees version 0.6.3'")
        default.succeed("deno --version 2>&1 | tee /dev/stderr | grep 'deno 1.6.1'")
        default.succeed("nix --version | tee /dev/stderr | grep '2.4pre20201201_5a6ddb3'")
        default.succeed(
            "(nginx-prometheus-exporter || true) 2>&1 | head -n1 | tee /dev/stderr | grep ' Version=0.8.0 '"
        )
      '';
  }
)
