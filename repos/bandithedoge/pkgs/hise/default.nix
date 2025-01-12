{
  pkgs,
  sources,
  utils,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.hise) pname version src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    pkg-config
    unzip
  ];

  buildInputs =
    utils.juce.commonBuildInputs
    ++ (with pkgs; [
      libjack2
      gtk3
      webkitgtk_4_0
    ]);

  preBuild = let
    projucerLibPath = pkgs.lib.makeLibraryPath (with pkgs; [
      freetype
      stdenv.cc.cc.lib
    ]);
  in ''
    unzip tools/SDK/sdk.zip -d tools/SDK

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${projucerLibPath}" \
      tools/projucer/Projucer

    mkdir -p $out
    cp -r . $out/libexec

    tools/projucer/Projucer --resave "projects/standalone/HISE Standalone.jucer"

    cd projects/standalone/Builds/LinuxMakefile
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp "build/HISE Standalone" $out/bin/HISE
  '';

  enableParallelBuilding = true;

  makeFlags = "CONFIG=Release";

  dontStrip = true;

  meta = with pkgs.lib; {
    description = "The open source toolkit for building virtual instruments and audio effects";
    homepage = "https://hise.dev";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
