{lib, stdenv, fetchurl, cups, dpkg, libgcc, autoPatchelfHook}:

let
  version = "1.2.0";
  dp27_deb = fetchurl {
    url = "https://detonger.com/driver/deb/amd/com.detonger.dp27_${version}_amd64.deb";
    sha256 = "2a2bac8a88110f47bb3b55e4aad81ea209ea009c458d9d9c078af00444067423";
  };
in
stdenv.mkDerivation {
  pname = "cups-detonger";
  inherit version;

  srcs = [ dp27_deb ];
  nativeBuildInputs = [ autoPatchelfHook dpkg ];
  buildInputs = [ cups libgcc ];
  unpackPhase = ''
    dpkg-deb -x ${dp27_deb} .
    '';
  installPhase = ''
    mkdir -p $out

    mv ./opt $out
    mv ./usr/share $out/share
    mv ./usr/lib $out/lib
    '';

  meta = {
    homepage = "https://detonger.com";
    description = "Detong label printer driver for CUPS";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
    downloadPage = "https://detonger.com/software-linux-driver-download.html";
  };
}
