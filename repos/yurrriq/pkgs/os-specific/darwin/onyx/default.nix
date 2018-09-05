{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  name = "onyx-${version}";
  version = "3.4.8";

  src = fetchurl {
    url = "https://www.titanium-software.fr/download/1013/OnyX.dmg";
    sha256 = "16068q1mamjly6gzdqwcapgczc3fwnch77ls4ymwm5sj51paifsm";
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
