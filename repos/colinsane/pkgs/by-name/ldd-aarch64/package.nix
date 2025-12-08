{
  linkFarm,
  pkgsCross,
}:

linkFarm "ldd-aarch64" [{
  # create a `ldd-aarch64` alias to easily run ldd on aarch64 binaries
  name = "bin/ldd-aarch64";
  path = "${pkgsCross.aarch64-multiplatform.glibc.bin}/bin/ldd";
}]
