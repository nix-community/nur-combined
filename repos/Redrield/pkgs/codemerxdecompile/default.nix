{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, lttng-ust_2_12
, fontconfig
, zlib }:
stdenv.mkDerivation rec {
  name = "CodemerxDecompile";

  src = fetchurl {
    url = meta.downloadPage;
    sha256 = "1f6kjb0il4b15n0dk6b74xw0hly4y8a5wy472jhrg1ap8rbg1x8k";
  };

  # Archive contains no subdirectory workaround
  sourceRoot = "."; 

  buildInputs = [
    stdenv.cc.cc.lib # libstdc++.so.6
    fontconfig
    lttng-ust_2_12 # liblttng-ust.so.0
    zlib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/opt/codemerxdecompile
    cp -r * $out/opt/codemerxdecompile
    ls $out/opt/codemerxdecompile
    chmod +x $out/opt/codemerxdecompile/CodemerxDecompile
    makeWrapper $out/opt/codemerxdecompile/CodemerxDecompile \
      $out/bin/CodemerxDecompile
  '';

  meta = with lib; {
  # https://github.com/codemerx/CodemerxDecompile/releases/download/1.4.0/CodemerxDecompile-linux-x64.tar.gz
    version = "1.4.0";
    downloadPage = "https://github.com/codemerx/CodemerxDecompile/releases/download/${version}/CodemerxDecompile-linux-x64.tar.gz";
    description = "The first standalone .NET decompiler for Mac, Linux and Windows.";
    homepage = "https://decompiler.codemerx.com/";
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
  };
}
