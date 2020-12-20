{ pkgs, config, lib, ... }: with lib; {
  options.systemd = {
    package = mkOption {
      type = types.package;
      default = pkgs.systemd;
      defaultText = "pkgs.systemd";
    };
  };
}
