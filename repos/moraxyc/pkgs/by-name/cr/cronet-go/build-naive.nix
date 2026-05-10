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
  vendorHash = "sha256-tVIKTznnducPfATK151TpC3UV2U852TyclBTSgh/H6U=";
  patches = [
    (replaceVars ./build-naive.patch {
      gn = lib.getExe gn;
    })
  ];
  subPackages = [ "cmd/build-naive" ];
  meta.mainProgram = "build-naive";
}
