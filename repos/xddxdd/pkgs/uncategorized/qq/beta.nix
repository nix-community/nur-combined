{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, lib
  # Dependencies
, alsa-lib
, gtk3
, krb5
, libdrm
, libgcrypt
, libva
, mesa
, nspr
, nss
, pciutils
, systemd
, xorg
, ...
} @ args:

let
  libraries = [
    alsa-lib
    gtk3
    krb5
    libdrm
    libgcrypt
    libva
    mesa.drivers
    nspr
    nss
    pciutils
    systemd
    xorg.libXdamage
  ];
in
stdenv.mkDerivation rec {
  pname = "qq";
  version = "2.0.1";
  src = fetchurl {
    url = "https://dldir1.qq.com/qqfile/qq/QQNT/4691a571/QQ-v2.0.1-429_x64.deb";
    sha256 = "0hpa8c3bsgrikgram5b9cyyjcrx51h1cc4rrvxavd2g0dbzibap3";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = libraries;

  unpackPhase = ''
    ar x ${src}
  '';

  installPhase = ''
    mkdir -p $out/bin
    tar xf data.tar.xz -C $out
    mv $out/usr/* $out/
    mv $out/opt/QQ/* $out/opt/
    rm -rf $out/opt/QQ $out/usr

    makeWrapper $out/opt/qq $out/bin/qq \
      --argv0 "qq" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"
  '';

  meta = with lib; {
    description = "(HIGHLY EXPERIMENTAL) QQ beta edition";
    homepage = "https://im.qq.com/linuxqq/index.html";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
