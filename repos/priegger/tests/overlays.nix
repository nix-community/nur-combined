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
            brlaser
            cadvisor
            freeciv
            prometheus-nginx-exporter
            prometheus-pushgateway
          ];
        };
      };

    testScript =
      ''
        default.succeed("cadvisor --version 2>&1 | tee /dev/stderr | grep '0.38.7'")
        default.succeed("freeciv-sdl --version 2>&1 | tee /dev/stderr | grep '2.6.3'")
        default.succeed(
            "(nginx-prometheus-exporter || true) 2>&1 | head -n1 | tee /dev/stderr | grep ' Version=0.8.0 '"
        )
        default.succeed("pushgateway --version 2>&1 | tee /dev/stderr | grep 'version 1.3.1'")
      '';
  }
)
