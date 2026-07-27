{
  sources,

  lib,
  stdenv,
}:
let
  source =
    sources."git-pages-bin-${stdenv.targetPlatform.system}" or sources.git-pages-bin-x86_64-linux;
in
stdenv.mkDerivation {
  pname = "git-pages-bin";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    cp $src $out/bin/git-pages
    chmod +x $out/bin/git-pages

    runHook postBuild
  '';

  meta = {
    description = "Scalable static site server for Git forges (like GitHub Pages or Netlify)";
    homepage = "https://git-pages.org";
    license = lib.licenses.bsd0;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "git-pages";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
