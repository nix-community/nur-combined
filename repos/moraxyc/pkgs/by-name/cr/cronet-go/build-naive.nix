{
  lib,
  buildGoModule,
  gn,
  replaceVars,

  sources,
  source ? sources.cronet-go,
}:
buildGoModule {
  pname = source.pname + "-build-naive";
  inherit (source) version src;
  vendorHash = "sha256-pyeE+JPuRQEjNzrF+o9jslBcBM1vruuL+I/DCIa2BG0=";
  patches = [
    (replaceVars ./build-naive.patch {
      gn = lib.getExe gn;
    })
  ];
  subPackages = [ "cmd/build-naive" ];
  meta.mainProgram = "build-naive";
}
