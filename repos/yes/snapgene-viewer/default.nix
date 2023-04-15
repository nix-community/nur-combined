{ lib
, stdenv
, fetchurl
, rpmextract
, autoPatchelfHook
, dbus
, expat
, fontconfig
, freetype
, krb5
, libcxx
, libcxxabi
, libGL
, libxkbcommon
, makeWrapper
, nspr
, nss
, openssl_1_1
, xorg
, xz
, zlib
}:

let
  majorVersion = "6";
  minorVersion = "2";
in
stdenv.mkDerivation rec {
  pname = "snapgene-viewer";
  version = "${majorVersion}.${minorVersion}.2";

  src = fetchurl {
    url = "https://cdn.snapgene.com/downloads/SnapGeneViewer/${majorVersion}.x/${majorVersion}.${minorVersion}/${version}/snapgene_viewer_${version}_linux.rpm";
    hash = "sha256-DfHCUP7/OwMlDhu0tm255JeNYzX9m4B8YZB4on4ZQfQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    rpmextract
  ];

  buildInputs = [
    dbus
    expat
    fontconfig
    freetype
    krb5
    libcxx
    libcxxabi
    libGL
    libxkbcommon
    nspr
    nss
    openssl_1_1
    xorg.libICE
    xorg.libSM
    xorg.libxcb
    xorg.libxkbfile
    xorg.libxshmfence
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xz
    zlib
  ];

  unpackPhase = ''
    rpmextract $src
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp -r opt/gslbiotech/${pname}/ $out/lib/
    mv $out/lib/${pname}/lib{*.so,{q*,hts}.so.*,Qt6*} $out/lib/
    rm $out/lib/${pname}/{lib*.so.*,${pname}.sh}
    makeWrapper $out/lib/${pname}/${pname} $out/bin/${pname} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        openssl_1_1
        xorg.libXcursor
      ]} \
      --set LANG C

    cp -r usr/share $out
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace /opt/gslbiotech/${pname}/${pname}.sh ${pname} \
      --replace /opt/gslbiotech/ $out/lib/
  '';

  meta = with lib; {
    description = "An easy-to-use program for viewing, annotating, and printing DNA and protein sequences";
    homepage = "https://www.snapgene.com/${pname}}";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}