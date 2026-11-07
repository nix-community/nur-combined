{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.k3sStorage;
  driverVersion = "v4.13.6";
  driverBase = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/${driverVersion}/deploy";
  fetchDriverFile =
    file: hash:
    pkgs.fetchurl {
      url = "${driverBase}/${file}";
      inherit hash;
    };
in
{
  options.nixcfg.k3sStorage = {
    enable = lib.mkEnableOption "shared NFS storage for k3s (csi-driver-nfs + static pool PVs)";
  };

  # Single writer: enable ONLY on nas. Addons are cluster objects shared
  # across servers, and a second writer with --disable flags uninstalled
  # a shared chart once already (traefik, 2026-10-25). No manifests here
  # may ever be set on another server.
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sStorage: storage manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      "csi-nfs-driverinfo.yaml".source =
        fetchDriverFile "csi-nfs-driverinfo.yaml" "sha256-+iu6RnSCGzMX0eAW88nVSr4E/Nxv7T/OnliZTIMRxKA=";
      "csi-nfs-controller.yaml".source =
        fetchDriverFile "csi-nfs-controller.yaml" "sha256-cGv45prAPoEM7IBr7REFCFBYjKthWqZdEqYQHOz9OHE=";
      "csi-nfs-node.yaml".source =
        fetchDriverFile "csi-nfs-node.yaml" "sha256-JqnuHJ3mYIWYrJCDknqSKncyP4kzuig01hpmW20j9pI=";
      "csi-nfs-rbac.yaml".source =
        fetchDriverFile "rbac-csi-nfs.yaml" "sha256-MS3midB2JzMNgoDlDXtRNX4LX1yg2Kp1eUrsRg7kz/A=";

      "pool-pvs.yaml".content = [
        {
          apiVersion = "v1";
          kind = "PersistentVolume";
          metadata.name = "pool-k3s-test";
          spec = {
            capacity.storage = "50Gi";
            volumeMode = "Filesystem";
            accessModes = [ "ReadWriteMany" ];
            persistentVolumeReclaimPolicy = "Retain";
            storageClassName = "nfs-pool";
            mountOptions = [ "vers=4.2" ];
            csi = {
              driver = "nfs.csi.k8s.io";
              volumeHandle = "nas-pool-k3s-test";
              volumeAttributes = {
                server = "10.1.0.3";
                share = "/mnt/POOL/k3s-test";
              };
            };
          };
        }
        {
          apiVersion = "v1";
          kind = "PersistentVolume";
          metadata.name = "pool-public-ro";
          spec = {
            capacity.storage = "4Ti";
            volumeMode = "Filesystem";
            accessModes = [ "ReadOnlyMany" ];
            persistentVolumeReclaimPolicy = "Retain";
            storageClassName = "nfs-pool";
            mountOptions = [
              "vers=4.2"
              "ro"
            ];
            csi = {
              driver = "nfs.csi.k8s.io";
              readOnly = true;
              volumeHandle = "nas-pool-public-ro";
              volumeAttributes = {
                server = "10.1.0.3";
                share = "/mnt/POOL/Public";
              };
            };
          };
        }
        {
          apiVersion = "v1";
          kind = "PersistentVolume";
          metadata.name = "pool-media-lidarr-rw";
          spec = {
            capacity.storage = "4Ti";
            volumeMode = "Filesystem";
            accessModes = [ "ReadWriteMany" ];
            persistentVolumeReclaimPolicy = "Retain";
            storageClassName = "nfs-pool";
            mountOptions = [ "vers=4.2" ];
            csi = {
              driver = "nfs.csi.k8s.io";
              volumeHandle = "nas-pool-media-lidarr-rw";
              volumeAttributes = {
                server = "10.1.0.3";
                share = "/mnt/POOL/Public";
              };
            };
          };
        }
        {
          apiVersion = "v1";
          kind = "PersistentVolume";
          metadata.name = "pool-media-radarr-rw";
          spec = {
            capacity.storage = "4Ti";
            volumeMode = "Filesystem";
            accessModes = [ "ReadWriteMany" ];
            persistentVolumeReclaimPolicy = "Retain";
            storageClassName = "nfs-pool";
            mountOptions = [ "vers=4.2" ];
            csi = {
              driver = "nfs.csi.k8s.io";
              volumeHandle = "nas-pool-media-radarr-rw";
              volumeAttributes = {
                server = "10.1.0.3";
                share = "/mnt/POOL/Public";
              };
            };
          };
        }
        {
          apiVersion = "v1";
          kind = "PersistentVolume";
          metadata.name = "pool-media-readarr-rw";
          spec = {
            capacity.storage = "4Ti";
            volumeMode = "Filesystem";
            accessModes = [ "ReadWriteMany" ];
            persistentVolumeReclaimPolicy = "Retain";
            storageClassName = "nfs-pool";
            mountOptions = [ "vers=4.2" ];
            csi = {
              driver = "nfs.csi.k8s.io";
              volumeHandle = "nas-pool-media-readarr-rw";
              volumeAttributes = {
                server = "10.1.0.3";
                share = "/mnt/POOL/Public";
              };
            };
          };
        }
        {
          apiVersion = "v1";
          kind = "PersistentVolume";
          metadata.name = "pool-media-bazarr-rw";
          spec = {
            capacity.storage = "4Ti";
            volumeMode = "Filesystem";
            accessModes = [ "ReadWriteMany" ];
            persistentVolumeReclaimPolicy = "Retain";
            storageClassName = "nfs-pool";
            mountOptions = [ "vers=4.2" ];
            csi = {
              driver = "nfs.csi.k8s.io";
              volumeHandle = "nas-pool-media-bazarr-rw";
              volumeAttributes = {
                server = "10.1.0.3";
                share = "/mnt/POOL/Public";
              };
            };
          };
        }
        {
          apiVersion = "v1";
          kind = "PersistentVolume";
          metadata.name = "pool-media-qbittorrent-rw";
          spec = {
            capacity.storage = "4Ti";
            volumeMode = "Filesystem";
            accessModes = [ "ReadWriteMany" ];
            persistentVolumeReclaimPolicy = "Retain";
            storageClassName = "nfs-pool";
            mountOptions = [ "vers=4.2" ];
            csi = {
              driver = "nfs.csi.k8s.io";
              volumeHandle = "nas-pool-media-qbittorrent-rw";
              volumeAttributes = {
                server = "10.1.0.3";
                share = "/mnt/POOL/Public";
              };
            };
          };
        }
        {
          apiVersion = "v1";
          kind = "PersistentVolume";
          metadata.name = "pool-media-rw";
          spec = {
            capacity.storage = "4Ti";
            volumeMode = "Filesystem";
            accessModes = [ "ReadWriteMany" ];
            persistentVolumeReclaimPolicy = "Retain";
            storageClassName = "nfs-pool";
            mountOptions = [ "vers=4.2" ];
            csi = {
              driver = "nfs.csi.k8s.io";
              volumeHandle = "nas-pool-media-rw";
              volumeAttributes = {
                server = "10.1.0.3";
                share = "/mnt/POOL/Public";
              };
            };
          };
        }
      ];
    };
  };
}
