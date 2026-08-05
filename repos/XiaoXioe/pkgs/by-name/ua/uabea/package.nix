{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  zlib,
  openssl,
  icu,
  fontconfig,
  libx11,
  libice,
  libsm,
  dotnet-runtime_8,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uabea";
  version = "8";

  src = fetchurl {
    url = "https://github.com/nesrak1/UABEA/releases/download/v${finalAttrs.version}/uabea-ubuntu.zip";
    hash = "sha256-xULdO1sJGzRkXuHHGA33E4+fP+UlMiLxUdcYXlQkArI=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    openssl
    icu
    fontconfig
    libx11
    libice
    libsm
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/uabea $out/bin
    cp -r * $out/opt/uabea/

    makeWrapper ${dotnet-runtime_8}/bin/dotnet $out/bin/uabea \
      --add-flags "$out/opt/uabea/UABEAvalonia.dll" \
      --set DOTNET_ROLL_FORWARD "Major" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          fontconfig
          libx11
          libice
          libsm
          zlib
          openssl
          icu
        ]
      }"

    runHook postInstall
  '';

  meta = {
    description = "C# UABE for newer versions of Unity (DLL Bypass)";
    homepage = "https://github.com/nesrak1/UABEA";
    license = lib.licenses.mit;
    mainProgram = "uabea";
    platforms = [ "x86_64-linux" ];
  };
})
