{
  stdenv,
  fetchurl,
  p7zip,
  libarchive,
  lib,
}:

stdenv.mkDerivation rec {
  name = "sf-pro";
  version = "1.0.0";
  src = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    hash = "sha256-IccB0uWWfPCidHYX6sAusuEZX906dVYo8IaqeX7/O88=";
  };

  nativeBuildInputs = [
    p7zip
    libarchive
  ];

  unpackPhase = ''
    mkdir -p $TMPDIR/SF-Pro-${version}
    cd $TMPDIR/SF-Pro-${version}
    7z x $src
    bsdtar xvPf "SFProFonts/SF Pro Fonts.pkg"
    bsdtar xvPf "SFProFonts.pkg/Payload"
  '';
  installPhase = ''
    runHook preInstall
    cd $TMPDIR/SF-Pro-${version}
    find ./Library/Fonts -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://developer.apple.com/fonts/";
    description = "Apple's SF Pro Font";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
