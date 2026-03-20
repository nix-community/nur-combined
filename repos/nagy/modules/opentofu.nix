{ pkgs, ... }:

let
  self = import ../. { inherit pkgs; };
in
{
  imports = [ ./shortcommands.nix ];

  environment.systemPackages = [
    (pkgs.opentofu.withPlugins (p: [
      p.integrations_github
      p.gitlabhq_gitlab
      p.hetznercloud_hcloud
      p.terraform-provider-openstack_openstack
    ]))
    # pkgs.opentofu-ls
    self.pug

  ];

  environment.sessionVariables.PUG_PROGRAM = "tofu";

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
