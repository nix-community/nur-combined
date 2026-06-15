{
  lib,
  stdenvNoCC,
  fetchzip,
  autoPatchelfHook,
  libgcc,
  curl,
  zlib,
  ignoreCurl ? false, # workaround for box64
  ...
}:
let
  pname = "futu-opend";
  version = "10.7.6718";
  variant = "Ubuntu18.04";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://softwaredownload.futunn.com/Futu_OpenD_${version}_${variant}.tar.gz";
    sha256 = "sha256-NRFGDO3zojiRl/ZoH0ZDFN4ho24rJuD6LFrhKMwsmNA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    libgcc.lib
    zlib
  ]
  ++ lib.optionals (!ignoreCurl) [
    curl
  ];

  autoPatchelfIgnoreMissingDeps = lib.optionals ignoreCurl [
    "libcurl.so.4"
    "libssl.so.3"
    "libcrypto.so.3"
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/share"

    cp -r $src/Futu_OpenD_${version}_${variant}/* "$out/"

    rm "$out/libcrypto.so.3" "$out/libcurl.so.4" "$out/libssl.so.3"

    rm "$out/FTUpdate"
    ln -s "$out/FTWebSocket" "$out/bin/"
    ln -s "$out/FutuOpenD" "$out/bin/"

    mv "$out/FutuOpenD.xml" "$out/share/"
  '';

  meta = with lib; {
    description = "OpenD is the gateway program of Futu API, running on your local computer or cloud server. It is responsible for transferring the protocol requests to Futu servers, and returning the processed data.";
    homepage = "https://openapi.futunn.com/futu-api-doc/opend/opend-intro.html";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
