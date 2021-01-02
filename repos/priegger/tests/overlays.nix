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
            cadvisor
            prometheus-nginx-exporter
          ];
        };
      };

    testScript =
      ''
        default.succeed("beesd --help 2>&1 | tee /dev/stderr | grep 'bees version 0.6.3'")
        default.succeed("cadvisor --version 2>&1 | tee /dev/stderr | grep '0.37.0'")
        default.succeed(
            "(nginx-prometheus-exporter || true) 2>&1 | head -n1 | tee /dev/stderr | grep ' Version=0.8.0 '"
        )
      '';
  }
)
