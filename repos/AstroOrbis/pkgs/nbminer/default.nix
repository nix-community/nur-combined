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
  pname = "nbminer";
  version = "42.3";

  src = fetchurl {
    url = "https://github.com/NebuTech/NBMiner/releases/download/v${finalAttrs.version}/NBMiner_${finalAttrs.version}_Linux.tgz";
    hash = "sha256-h5apXAeNGkaKy7uyKRXmS6CZ3aVtmsBy2qMvkBEnxk4=";
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

      install -Dm755 nbminer $out/libexec/nbminer
      install -Dm644 readme.md $out/share/doc/${finalAttrs.pname}/readme.md

      # --library-path for resolution, LD_LIBRARY_PATH for libcuda dlopen
      makeWrapper ${glibc}/lib/ld-linux-x86-64.so.2 $out/bin/nbminer \
        --add-flags "--library-path ${libPath}" \
        --add-flags "$out/libexec/nbminer" \
        --prefix LD_LIBRARY_PATH : "${libPath}"

      runHook postInstall
    '';

  meta = {
    description = "NBMiner GPU miner for NVIDIA and AMD cards";
    homepage = "https://github.com/NebuTech/NBMiner";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "nbminer";
    maintainers = [ ];
  };
})
