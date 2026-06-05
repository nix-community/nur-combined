{
  linkFarm,
  pkgsCross,
}:

linkFarm "ldd-aarch64" {
  # create a `ldd-aarch64` alias to easily run ldd on aarch64 binaries
  "bin/ldd-aarch64" = "${pkgsCross.aarch64-multiplatform.glibc.bin}/bin/ldd";
}
