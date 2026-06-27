{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  patchelf,
  unzip,
  zip,
  wl-clipboard,
  xclip,
  espeak-ng,
}:

let
  runtimeDeps = [
    unzip
    zip
    wl-clipboard
    xclip
    espeak-ng
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rikkahub-desktop-bin";
  version = "1.3.1";

  src = fetchurl {
    url = "https://github.com/yuh-G/rikkahub-desktop/releases/download/v${finalAttrs.version}/Rikkahub_${finalAttrs.version}_linux_x64.tar.gz";
    hash = "sha256-QlTSD0f5eIInj4PRkd8nHrBQFo8WndOeCmQ7GyEtnQY=";
  };

  nativeBuildInputs = [
    makeWrapper
    patchelf
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/rikkahub
    cp -r . $out/lib/rikkahub

    patchelf \
      --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      --set-rpath ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]} \
      $out/lib/rikkahub/rikkahub-pc

    mkdir -p $out/bin
    makeWrapper $out/lib/rikkahub/rikkahub-pc $out/bin/rikkahub-pc \
      --prefix PATH : ${lib.makeBinPath runtimeDeps} \
      --run 'export RIKKAHUB_PC_DATA_DIR="$HOME/.rikkahub"'
    ln -s $out/bin/rikkahub-pc $out/bin/rikkahub-desktop

    runHook postInstall
  '';

  meta = {
    description = "RikkaHub desktop prebuilt binary release";
    homepage = "https://github.com/yuh-G/rikkahub-desktop";
    mainProgram = "rikkahub-pc";
    license = {
      shortName = "rikkahub-segmented-dual";
      fullName = "RikkaHub Segmented Dual License";
      url = "https://github.com/yuh-G/rikkahub-desktop/blob/v${finalAttrs.version}/LICENSE";
      free = false;
      redistributable = true;
    };
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
