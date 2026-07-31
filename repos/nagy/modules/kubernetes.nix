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
    pkgs.crane.out # whould not select the "crane" output
    pkgs.sops
    pkgs.imgpkg

    # carvel tools, useful for k8s development
    pkgs.ytt
    pkgs.vendir
    pkgs.yamllint
    pkgs.sops
    pkgs.kustomize
    pkgs.kustomize-sops
    pkgs.argocd-vault-plugin
    pkgs.butane
    pkgs.kbld

    pkgs.hadolint
    pkgs.dive

    pkgs.clusterctl

    pkgs.cmctl # https://github.com/cert-manager/cmctl

    pkgs.jwt-cli
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
  };
}
