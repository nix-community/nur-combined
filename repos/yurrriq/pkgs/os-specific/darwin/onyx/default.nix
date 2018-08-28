{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  name = "onyx-${version}";
  version = "3.4.7";

  src = fetchurl {
    url = "https://www.titanium-software.fr/download/1013/OnyX.dmg";
    sha256 = "02wkh6ryjhwzw4v27w58l6bj0p75yk2qfw49kh456zg9wx2fgc9g";
  };

  buildInputs = [ undmg ];

  setSourceRoot = ''
    sourceRoot=OnyX.app
  '';

  installPhase = ''
    install -m755 -d "$out/Applications/OnyX.app"
    cp -R . "$_"
  '';

  meta = with stdenv.lib; {
    description = "A multifunction utility";
    homepage = https://www.titanium-software.fr/en/onyx.html;
    # TODO: license
    platforms = platforms.darwin;
    maintainers = with maintainers; [ yurrriq ];
  };
}
