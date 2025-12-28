{
  lib,
  vaculib,

  writers,

  nssTools,
  shellvaculib,
}:
writers.writeBashBin "make-client-cert" {
  makeWrapperArgs = [
    "--prefix" "PATH" ":" (lib.makeBinPath [ nssTools shellvaculib ])
  ];
} (vaculib.path ./main.sh)
