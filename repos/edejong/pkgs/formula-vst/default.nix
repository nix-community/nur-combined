{
  lib,
  stdenvNoCC,

  cpio,
  fetchzip,
  makeWrapper,
  xar,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "formula-binary-app";
  version = "1.2.1";

  src = fetchzip {
    url = "https://github.com/soundspear/formula/releases/download/${finalAttrs.version}/formula-macos.zip";
    hash = "sha256-T9Iv6HVzA3Ik/kn0TJYSl3KJcoOQ5ciUJ+bkfffxpuM=";
    stripRoot = false;
  };

  meta = {
    description = "Formula is an open-source VST & AU plugin to create custom audio effects inside your DAW.";
    homepage = "https://soundspear.com/product/formula";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.boost;
    platforms = [
      # "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "formula";
  };

  nativeBuildInputs = [
    cpio
    makeWrapper
    xar
  ];

  unpackPhase = ''
    xar -xf $src/Formula_Standalone_Application.pkg
    zcat < Payload | cpio -i

    xar -xf $src/Formula_AU.pkg
    zcat < Payload | cpio -i

    xar -xf $src/Formula_VST3.pkg
    zcat < Payload | cpio -i
  '';

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{Applications,bin}
    cp -R ./Formula.app $out/Applications/
    makeWrapper $out/Applications/Formula.app/Contents/MacOS/Formula $out/bin/formula

    mkdir -p $out/Library/Audio/Plug-Ins/{Components,VST3}
    cp -R ./Formula.component $out/Library/Audio/Plug-Ins/Components/
    cp -R ./Formula.VST3 $out/Library/Audio/Plug-Ins/VST3/

    runHook postInstall
  '';
})
