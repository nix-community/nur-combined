{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.opentofu;
in
{
  imports = [ ./shortcommands.nix ];

  options.nagy.opentofu = {
    enable = lib.mkEnableOption "opentofu config";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      (pkgs.opentofu.withPlugins (p: [
        # p.aws
        p.github
        p.gitlab
        # p.vultr
        p.hcloud
        # p.backblaze
      ]))
      # pkgs.opentofu-ls
    ];

    nagy.shortcommands.commands = {
      # tf = [ "tofu" ];
      tfp = [
        "tofu"
        "plan"
      ];
      tfa = [
        "tofu"
        "apply"
      ];
      tfs = [
        "tofu"
        "show"
      ];
      tfo = [
        "tofu"
        "output"
      ];
    };
  };
}
