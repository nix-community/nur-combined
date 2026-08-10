{
  lib,
  cronet-go,
  replaceVars,
  stdenvNoCC,

  # buildInputs
  darwin,
}:

cronet-go.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "150.0.7871.63-1";

  src = previousAttrs.src.override {
    rev = "7e27f60f7f04a1c762b6bb69b4a44d7b24cd7a5d";
    hash = "sha256-dTKKl32saIIVt8ue105Xw643TBNEf09H38GbSdEcmKQ=";
  };

  patches = [
    ./cflags.patch
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin (
    replaceVars ./libresolv.patch {
      libresolv = lib.getInclude darwin.libresolv;
    }
  );

  postPatch = previousAttrs.postPatch or "" + ''
    patchShebangs --build naiveproxy/src/build/toolchain/apple/linker_driver.py
  '';
})
