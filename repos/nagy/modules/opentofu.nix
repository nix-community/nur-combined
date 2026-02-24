{ pkgs, ... }:

{
  imports = [ ./shortcommands.nix ];

  environment.systemPackages = [
    (pkgs.opentofu.withPlugins (p: [
      p.integrations_github
      p.gitlabhq_gitlab
      p.hetznercloud_hcloud
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
}
