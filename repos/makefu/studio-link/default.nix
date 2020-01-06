{ stdenv
, fetchurl
, alsaLib
, unzip
, openssl_1_0_2
, zlib
, libjack2
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  name = "studio-link-${version}";
  version = "17.03.1-beta";
  src = fetchurl {
    url = "https://github.com/Studio-Link-v2/backend/releases/download/v${version}/studio-link-standalone-linux.zip";
    sha256 = "1y21nymin7iy64hcffc8g37fv305b1nvmh944hkf7ipb06kcx6r9";
  };
  nativeBuildInputs = [ unzip autoPatchelfHook ];
  buildInputs = [
      alsaLib

      openssl_1_0_2
      zlib
      libjack2
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp studio-link-standalone $out/bin/studio-link
    chmod +x $out/bin/studio-link
  '';

  meta = with stdenv.lib; {
    homepage = https://studio-link.com;
    description = "Voip transfer";
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };
}
