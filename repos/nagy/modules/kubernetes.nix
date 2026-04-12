{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./shortcommands.nix ];

  environment.systemPackages = [
    pkgs.kubernetes-helm
    pkgs.argocd
    pkgs.k9s
    pkgs.crane
    # pkgs.calicoctl
    pkgs.nerdctl
    # pkgs.cri-tools
    pkgs.kind
    pkgs.kubeconform

    # carvel tools, useful for k8s development
    pkgs.ytt
    pkgs.vendir
    pkgs.yamllint
    pkgs.sops
    pkgs.kustomize
    pkgs.kustomize-sops
  ]
  ++ (lib.optionals (!config.services.k3s.enable) [
    pkgs.kubectl # this otherwise conflicts with the k3s provided binary
  ]);

  virtualisation.containerd = {
    settings = {
      plugins."io.containerd.grpc.v1.cri" = {
        # Example: enabling systemd cgroups for Kubernetes
        containerd.runtimes.runc.options.SystemdCgroup = true;
        cni.bin_dir = "${
          pkgs.symlinkJoin {
            name = "cni-plugins-with-flannel";
            paths = [
              pkgs.cni-plugins
              pkgs.cni-plugin-flannel
            ];
          }
        }/bin";
      };
    };
  };

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
    kgpw = [
      "kubectl"
      "get"
      "pod"
      "--watch"
    ];
    kgd = [
      "kubectl"
      "get"
      "deployment"
    ];
    kgdw = [
      "kubectl"
      "get"
      "deployment"
      "--watch"
    ];
    kgn = [
      "kubectl"
      "get"
      "node"
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
    keit = [
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
    # kx = [
    #   "kubectl"
    #   "delete"
    # ];
    kz = [
      "kustomize"
    ];
  };
}
