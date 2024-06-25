{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, lttng-ust_2_12
, fontconfig
, icu
, zlib 
, xorg
, openssl }:
stdenv.mkDerivation rec {
  pname = "CodemerxDecompile";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/codemerx/${pname}/releases/download/${version}/CodemerxDecompile-linux-x64.tar.gz";
    sha256 = "1f6kjb0il4b15n0dk6b74xw0hly4y8a5wy472jhrg1ap8rbg1x8k";
  };

  # Archive contains no subdirectory workaround
  sourceRoot = "."; 

  buildInputs = [
    stdenv.cc.cc.lib # libstdc++.so.6
    fontconfig
    lttng-ust_2_12 # liblttng-ust.so.0
    icu
    zlib
    xorg.libX11
    xorg.libICE
    xorg.libSM
    openssl
  ];

  runtimeDependencies = [
    icu
    xorg.libX11
    xorg.libICE
    xorg.libSM
    openssl
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  installPhase = let 
    libPath = lib.makeLibraryPath runtimeDependencies;
  in ''
    mkdir -p $out/opt/codemerxdecompile
    cp -r * $out/opt/codemerxdecompile
    ls $out/opt/codemerxdecompile
    chmod +x $out/opt/codemerxdecompile/CodemerxDecompile
    makeWrapper $out/opt/codemerxdecompile/CodemerxDecompile \
      $out/bin/CodemerxDecompile \
      --prefix LD_LIBRARY_PATH ":" "${libPath}"
  '';

  meta = with lib; {
    description = "The first standalone .NET decompiler for Mac, Linux and Windows.";
    homepage = "https://decompiler.codemerx.com/";
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
  };
}
