{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.charlatan) pname version src;

  sourceRoot = ".";

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  buildInputs = with pkgs; [
    systemd
    xorg.libxcb
    xorg.xcbutilkeysyms
  ];

  buildPhase = ''
    mkdir -p $out/{libexec,lib/vst3,lib/clap}
    cp Charlatan3.so $out/libexec
    cp -r presets $out/libexec

    ln -s $out/libexec/Charlatan3.so $out/lib/clap/Charlatan3.clap
    mkdir -p $out/lib/vst3/Charlatan3.vst3/Contents/x86_64-linux
    ln -s $out/libexec/Charlatan3.so $out/lib/vst3/Charlatan3.vst3/Contents/x86_64-linux/Charlatan3.so
  '';

  meta = with pkgs.lib; {
    description = "Charlatan is a virtual analog (VA) synthesizer with focus on sound quality and easy usability";
    homepage = "https://blaukraut.info/";
    license = licenses.unfree;
    systems = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
