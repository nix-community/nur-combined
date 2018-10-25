let
  krops = ./.;

  lib = import "${krops}/lib";
  pkgs = import "${krops}/pkgs" {};

  source = lib.evalSource [{
    nixos-config.file = toString (pkgs.writeText "nixos-config" ''
      { pkgs, ... }: {

        fileSystems."/" = { device = "/dev/sda1"; };
        boot.loader.systemd-boot.enable = true;
        services.openssh.enable = true;
        environment.systemPackages = [ pkgs.git ];
      }
    '');
  }];
in {
  test = pkgs.krops.writeTest "test" {
    force = true;
    source = source;
    target = "${lib.getEnv "HOME"}/krops-test";
  };
}
