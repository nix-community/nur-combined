{ stdenv, fetchurl, dpkg, unzip }:
stdenv.mkDerivation {
  version = "1.6.5";
  name = "autofirma";
  src = fetchurl {
    url = "https://estaticos.redsara.es/comunes/autofirma/currentversion/AutoFirma_Linux.zip";
    sha256 = "sha256:1zys8sl03fbh9w8b2kv7xldfsrz53yrhjw3yn45bdxzpk7yh4f5j";
  };

  unpackPhase = ''
    unzip $src
    dpkg -x AutoFirma_1_6_5.deb out
    cd out
  '';

  postPatch = ''
    substituteInPlace usr/bin/AutoFirma \
      --replace "/usr/lib" "$out/lib"
  '';

  buildInputs = [ dpkg unzip ];

  buildPhase = "true";

  installPhase = ''
    mkdir $out
    cp -r usr/* $out/
  '';

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    broken = true;
  };
}
