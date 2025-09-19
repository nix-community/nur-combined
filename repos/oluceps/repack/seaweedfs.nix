{
  reIf,
  config,
  ...
}:
let
  dataDir = "/three/sea";
in
reIf {
  services.seaweedfs = {
    enable = true;
    args = [
      "server"
      "-ip"
      "fdcc::3"
      "-s3"
      "-s3.config=${config.vaultix.secrets.weed-s3.path}"
      "-s3.allowEmptyFolder=false"
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
    ReadWritePaths = [ dataDir ];
  };
}
