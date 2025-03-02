{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.opentofu.withPlugins (p: [
      p.aws
      p.github
      p.gitlab
      p.vultr
      p.kubernetes
      # p.backblaze
    ]))
    # pkgs.opentofu-ls
  ];

  nagy.shortcommands = {
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
