{
  lib,
  stdenv,
  pkgs,
  autoPatchelfHook,
  libgcc,
  ...
}:
let
  name = "futu-opend";
  version = "9.6.5618";
  variant = "Ubuntu18.04";
in
stdenv.mkDerivation {
  inherit name version;

  src = pkgs.fetchzip {
    url = "https://softwaredownload.futunn.com/Futu_OpenD_${version}_${variant}.tar.gz";
    sha256 = "sha256-WdG92yqOytl6QWDTLvwKh6fLzZnq829+yATVnSBehu8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    libgcc.lib
  ];

  installPhase = ''
    mkdir -p $out/opt/futu-opend

    cp -r $src/Futu_OpenD_${version}_${variant}/* $out/opt/futu-opend/
  '';

  meta = with lib; {
    description = "OpenD is the gateway program of Futu API, running on your local computer or cloud server. It is responsible for transferring the protocol requests to Futu servers, and returning the processed data.";
    homepage = "https://openapi.futunn.com/futu-api-doc/opend/opend-intro.html";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
