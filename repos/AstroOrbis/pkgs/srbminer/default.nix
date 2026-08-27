{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  glibc,
  ocl-icd,
  addDriverRunpath,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srbminer-multi";
  version = "3.5.9";

  src = fetchurl {
    url =
      let
        dashed = builtins.replaceStrings [ "." ] [ "-" ] finalAttrs.version;
      in
      "https://github.com/doktor83/SRBMiner-Multi/releases/download/${finalAttrs.version}/SRBMiner-Multi-${dashed}-Linux.tar.gz";
    hash = "sha256-jwmIMWjuaBhlkuMmtTw7/px/fvKbAK5OxMuihO9U1gA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # don't trip the binary's corruption check
  dontPatchELF = true;
  dontStrip = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase =
    let
      libPath = lib.makeLibraryPath [
        stdenv.cc.cc.lib
        addDriverRunpath.driverLink
        ocl-icd
      ];
    in
    ''
      runHook preInstall

      install -Dm755 SRBMiner-MULTI $out/libexec/SRBMiner-MULTI
      install -Dm644 ReadMe.txt $out/share/doc/${finalAttrs.pname}/ReadMe.txt

      makeWrapper ${glibc}/lib/ld-linux-x86-64.so.2 $out/bin/SRBMiner-MULTI \
        --add-flags "--library-path ${libPath}" \
        --add-flags "$out/libexec/SRBMiner-MULTI" \
        --prefix LD_LIBRARY_PATH : "${libPath}"

      # lowercase alias
      ln -s SRBMiner-MULTI $out/bin/srbminer-multi

      runHook postInstall
    '';

  meta = {
    description = "SRBMiner-Multi CPU/GPU miner supporting many algorithms";
    homepage = "https://github.com/doktor83/SRBMiner-Multi";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "SRBMiner-MULTI";
    maintainers = [ ];
  };
})
