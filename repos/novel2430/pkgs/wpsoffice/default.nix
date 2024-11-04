# Basic File Structure from Github User : wineee
#   - https://github.com/wineee/nixpkgs/blob/9b24eada63306b1440b2cac7fcda2fa0b0bf95c1/pkgs/applications/office/wpsoffice/default.nix
{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, alsa-lib
, at-spi2-core
, libtool
, libxkbcommon
, nspr
, mesa
, libtiff
, udev
, gtk3
, qtbase
, xorg
, cups
, pango
, freetype
, autoreconfHook
, pkg-config
, libjpeg
, xz
, zlib
, libdeflate
}:
let
  # Bold font rendered abnormally when use freetype > 2.13.0
  # Pin on 2.13.0 until upstream fixes this issue
  # https://github.com/NixOS/nixpkgs/issues/279314
  freetype-wps = freetype.overrideAttrs (old: {
    pname = "freetype-wps";
    version = "2.13.0";
    src = fetchurl {
      url = "mirror://savannah/freetype/freetype-2.13.0.tar.xz";
      hash = "sha256-XuI6vQR2NsJLLUPGYl3K/GZmHRrKZN7J4NBd8pWSYkw=";
    };
  });
  libtiff-wps = libtiff.overrideAttrs (old: {
    pname = "libtiff";
    version = "4.4.0";
    src = fetchurl {
      url = "https://download.osgeo.org/libtiff/tiff-4.4.0.tar.gz";
      hash = "sha256-kXIjs3U4lZrKO3kNLXOqbmJraI4C3NonKuwkwvSYq+0=";
    };
    patches = [
      # FreeImage needs this patch
      ./headers.patch
      # libc++abi 11 has an `#include <version>`, this picks up files name
      # `version` in the project's include paths
      ./rename-version.patch
    ];
    postFixup = ''
      moveToOutput include/tif_dir.h $dev_private
      moveToOutput include/tif_config.h $dev_private
      moveToOutput include/tiffiop.h $dev_private
    '';
    nativeBuildInputs = [ autoreconfHook pkg-config ];
    propagatedBuildInputs = [ libjpeg xz zlib ];
    buildInputs = [ libdeflate ];
  });
 
in
stdenv.mkDerivation rec {
  pname = "wpsoffice";
  version = "11.1.0.11723";

  src = fetchurl {
    url = "https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/${lib.last (lib.splitString "." version)}/wps-office_${version}.XA_amd64.deb";
    hash = "sha256-/mMmIQ9p2U79vycokU0pMDa+ORuTphT1jNDh/x1JI7M=";
  };

  unpackCmd = "dpkg -x $src .";
  sourceRoot = ".";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    libtool
    libxkbcommon
    nspr
    mesa
    libtiff-wps
    udev
    gtk3
    qtbase
    xorg.libXdamage
    xorg.libXtst
    xorg.libXv
  ];

  dontWrapQtApps = true;

  runtimeDependencies = map lib.getLib [
    cups
    pango
  ];

  autoPatchelfIgnoreMissingDeps = [
    # distribution is missing libkappessframework.so
    "libkappessframework.so"
    # qt4 support is deprecated
    "libQtCore.so.4"
    "libQtNetwork.so.4"
    "libQtXml.so.4"
  ];

  installPhase = ''
    runHook preInstall
    prefix=$out/opt/kingsoft/wps-office
    mkdir -p $out
    cp -r opt $out
    cp -r usr/* $out
    for i in wps wpp et wpspdf; do
      substituteInPlace $out/bin/$i \
        --replace /opt/kingsoft/wps-office $prefix
    done
    for i in $out/share/applications/*;do
      substituteInPlace $i \
        --replace /usr/bin $out/bin
    done
    runHook postInstall
  '';

  preFixup = ''
    ln -s ${freetype-wps}/lib/libfreetype.so.* $out/opt/kingsoft/wps-office/office6/
    # The following libraries need libtiff.so.5, but nixpkgs provides libtiff.so.6
    patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/kingsoft/wps-office/office6/{libpdfmain.so,libqpdfpaint.so,qt/plugins/imageformats/libqtiff.so,addons/pdfbatchcompression/libpdfbatchcompressionapp.so}
    # dlopen dependency
    patchelf --add-needed libudev.so.1 $out/opt/kingsoft/wps-office/office6/addons/cef/libcef.so
  '';

  meta = with lib; {
    description = "Office suite, formerly Kingsoft Office";
    homepage = "https://www.wps.com";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ mlatus th0rgal rewine ];
  };
}
