{ pkgs, ... }:

{
  imports = [ ./shortcommands.nix ];

  environment.systemPackages = [
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.argocd
    pkgs.k9s
  ];

  nagy.shortcommands = {
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
}
