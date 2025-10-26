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
        # p.aws_aws
        p.integrations_github
        p.gitlabhq_gitlab
        # p.vultr_vultr
        p.hetznercloud_hcloud
        # p.backblaze_backblaze
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
