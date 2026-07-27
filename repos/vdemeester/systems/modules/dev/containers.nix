{ config, lib, pkgs, ... }:

let
  cfg = config.modules.dev.containers;
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types;
in
{
  options = {
    modules.dev.containers = {
      enable = mkEnableOption "Enable dev containers";
      docker = {
        enable = mkEnableOption "Enable docker containers";
        package = mkOption {
          default = pkgs.docker;
          description = "docker package to be used";
          type = types.package;
        };
        runcPackage = mkOption {
          default = pkgs.runc;
          description = "runc package to be used";
          type = types.package;
        };
      };
      podman = {
        enable = mkEnableOption "Enable podman containers";
      };
      buildkit = {
        enable = mkEnableOption "Enable podman containers";
        grpcAddress = mkOption {
          type = types.listOf types.str;
          default = [ "unix:///run/buildkit/buildkitd.sock" ];
          example = [ "unix:///run/buildkit/buildkitd.sock" "tcp://0.0.0.0:1234" ];
          description = lib.mdDoc ''
            A list of address to listen to for the grpc service.
          '';
        };
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      networking.firewall.checkReversePath = false;
      virtualisation.containers = {
        enable = true;
        containersConf.settings = {
          network = {
            default_subnet_pools = [
              # See https://github.com/kubernetes-sigs/kind/issues/2872 for this
              { "base" = "11.0.0.0/24"; "size" = 24; }
              {
                "base" = "192.168.129.0/24";
                "size" = 24;
              }
              { "base" = "192.168.130.0/24"; "size" = 24; }
              { "base" = "192.168.131.0/24"; "size" = 24; }
              { "base" = "192.168.132.0/24"; "size" = 24; }
            ];
          };
        };
      };
    }
    (mkIf cfg.docker.enable {
      virtualisation = {
        containerd = {
          enable = true;
        };
        buildkitd = {
          enable = true;
          settings = {
            grpc = {
              address = cfg.buildkit.grpcAddress;
            };
            worker.oci = {
              enabled = false;
            };
            worker.containerd = {
              enabled = true;
              platforms = [ "linux/amd64" "linux/arm64" ];
              namespace = "buildkit";
            };
            # FIXME: move to home
            registry = {
              "r.svc.home:5000" = {
                http = true;
                insecure = true;
              };
              "r.svc.home" = {
                http = true;
                insecure = true;
              };
            };
          };
        };
        docker = {
          enable = true;
          package = cfg.docker.package;
          liveRestore = false;
          storageDriver = "overlay2";
          daemon.settings = {
            experimental = true;
            bip = "172.26.0.1/16";
            runtimes = {
              "docker-runc" = {
                path = "${cfg.docker.runcPackage}/bin/runc";
              };
            };
            default-runtime = "docker-runc";
            containerd = "/run/containerd/containerd.sock";
            features = { buildkit = true; };
            insecure-registries = [ "172.30.0.0/16" "192.168.1.0/16" "10.100.0.0/16" "shikoku.home:5000" "r.svc.home:5000" "r.svc.home" ];
            seccomp-profile = ./my-seccomp.json;
          };
        };
      };
      environment.systemPackages = with pkgs; [
        docker-buildx
      ];
      networking.firewall.trustedInterfaces = [ "docker0" "podman" ];
    })
    (mkIf cfg.podman.enable {
      virtualisation.podman.enable = true;
    })
    (mkIf config.modules.profiles.work.redhat {
      # Red Hat specific setup for virtualisation (buildah, podman, skopeo)
      virtualisation = {
        containers = {
          registries = {
            search = [ "registry.fedoraproject.org" "registry.access.redhat.com" "registry.centos.org" "docker.io" "quay.io" ];
          };
          policy = {
            default = [{ type = "insecureAcceptAnything"; }];
            transports = {
              docker-daemon = {
                "" = [{ type = "insecureAcceptAnything"; }];
              };
            };
          };
        };
      };
    })
  ]);
}
