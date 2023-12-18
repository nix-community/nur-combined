{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.swift-mesonlsp-bin) pname version src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  buildInputs = with pkgs; [
    libgcc.lib
  ];

  buildPhase = ''
    mkdir -p $out/bin
    cp Swift-MesonLSP $out/bin
  '';

  sourceRoot = ".";

  meta = with pkgs.lib; {
    description = "An unofficial, unendorsed language server for meson written in Swift.";
    homepage = "https://github.com/JCWasmx86/Swift-MesonLSP";
    license = licenses.gpl3;
    platforms = ["x86_64-linux"];
  };
}
