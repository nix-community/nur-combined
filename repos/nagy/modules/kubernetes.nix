{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.kubernetes;
in
{
  imports = [ ./shortcommands.nix ];

  options.nagy.kubernetes = {
    enable = lib.mkEnableOption "zig config";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.kubectl
      pkgs.kubernetes-helm
      pkgs.argocd
      pkgs.k9s
      pkgs.crane
    ];

    nagy.shortcommands.commands = {
      k = [ "kubectl" ];
      kg = [
        "kubectl"
        "get"
      ];
      kgp = [
        "kubectl"
        "get"
        "pod"
      ];
      kgd = [
        "kubectl"
        "get"
        "deployment"
      ];
      kgn = [
        "kubectl"
        "get"
        "node"
      ];
      kgpw = [
        "kubectl"
        "get"
        "pod"
        "--watch"
      ];
      kgdw = [
        "kubectl"
        "get"
        "deployment"
        "--watch"
      ];
      kgnw = [
        "kubectl"
        "get"
        "node"
        "--watch"
      ];
      kgsw = [
        "kubectl"
        "get"
        "service"
      ];
      kd = [
        "kubectl"
        "describe"
      ];
      kdp = [
        "kubectl"
        "describe"
        "pod"
      ];
      kdd = [
        "kubectl"
        "describe"
        "deployment"
      ];
      kdn = [
        "kubectl"
        "describe"
        "node"
      ];
      kc = [
        "kubectl"
        "create"
      ];
      kcp = [
        "kubectl"
        "create"
        "pod"
      ];
      kcd = [
        "kubectl"
        "create"
        "deployment"
      ];
      kcj = [
        "kubectl"
        "create"
        "job"
      ];
      kcn = [
        "kubectl"
        "create"
        "namespace"
      ];
      ke = [
        "kubectl"
        "exec"
      ];
      keti = [
        "kubectl"
        "exec"
        "-it"
      ];
      kl = [
        "kubectl"
        "label"
      ];
      kw = [
        "kubectl"
        "wait"
      ];
      kr = [
        "kubectl"
        "run"
      ];
    };
  };
}
