{ pkgs, lib, ... }:

let
  dockerRootfs = lib.fetchDockerRootfs {
    imageName = "hub.omp.ru/public/sdk-build-tools";
    imageDigest = "sha256:331a56b839b43acedd34014ae5f7723ba9d30ebe2c141ce4cc5d8cff702752a7";
    hash = "sha256-+whD8xaccMQ+aZ6MF4M5I7JzDqI4ZHeYFsqVba0Tc20=";
    finalImageName = "hub.omp.ru/public/sdk-build-tools";
    finalImageTag = "5.1.6";
  };

  apptool = pkgs.writeShellScriptBin "apptool" ''
    set -e
    BIND_MOUNTS="$BIND_MOUNTS -b $PWD:/mnt"
    exec ${pkgs.proot}/bin/proot \
      -r ${dockerRootfs} \
      -b /dev -b /proc -b /sys -b /tmp -b /run -b /var \
      -w /mnt \
      /usr/bin/apptool "$@"
  '';
in
apptool
// {
  meta = {
    license = pkgs.lib.licenses.unfree;
    homepage = "https://developer.auroraos.ru/doc/sdk/tools/apptool";
    sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
    maintainers = [ "dmfrpro" ];
    description = "AuroraOS SDK Build Tools - apptool";
    longDescription = ''
      Tool for cross-building, signing and validation of RPM packages.
      It is a high-level wrapper around rpmbuild, rpmspec, rpmsign-external and rpm-validator.
    '';
    platforms = [ "x86_64-linux" ];
    mainProgram = "apptool";
  };
}
