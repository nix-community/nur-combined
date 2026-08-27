{
  flake.modules.nixos.seaweedfs =
    { config, ... }:
    let
      # filerDir = "/var/lib/sea-filer";
      dataDir = "/var/lib/sea-volume";
    in
    {
      vaultix.secrets.weed-s3 = {
        owner = "seaweedfs";
        group = "seaweedfs";
      };
      services.seaweedfs = {
        enable = true;
        args = [
          "server"
          "-ip"
          "fdcc::3"
          "-s3"
          "-s3.config=${config.vaultix.secrets.weed-s3.path}"
          "-s3.allowEmptyFolder=false"
          "-filer"
          "-filer.port=8889"
          "-dir=${dataDir}"
          "-volume.max=0"
          "-volume.hasSlowRead=false"
          "-volume.readBufferSizeMB=16"
          "-metricsIp=fdcc::3"
          "-metricsPort=9768"
        ];
      };

      systemd.services.seaweedfs.serviceConfig = {
        ReadWritePaths = [
          dataDir
        ];
        MemoryMax = "8G";
        MemoryHigh = "6G";
        Environment = [ "GOMEMLIMIT=6GiB" ];
      };

      environment.etc."seaweedfs/filer.toml".source = ./filer.toml;
    };
}
