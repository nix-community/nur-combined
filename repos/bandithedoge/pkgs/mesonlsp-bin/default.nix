{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.mesonlsp-bin) pname version src;

  nativeBuildInputs = with pkgs; [
    unzip
  ];

  buildPhase = ''
    mkdir -p $out/bin
    cp mesonlsp $out/bin
  '';

  sourceRoot = ".";

  meta = with pkgs.lib; {
    description = "An unofficial, unendorsed language server for meson written in C++.";
    homepage = "https://github.com/JCWasmx86/mesonlsp";
    license = licenses.gpl3;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
