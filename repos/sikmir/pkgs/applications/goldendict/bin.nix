{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "goldendict";
  version = "1.5.0-RC2-372-gc3ff15f";

  src = fetchurl {
    url = "https://downloads.sourceforge.net/project/goldendict/early%20access%20builds/MacOS/GoldenDict-${version}%28Qt_5121%29.dmg";
    sha256 = "1zvkwnpsybflgbgs3dvjcivrdpq4fc8njb96nsw507dmbnysq15w";
    name = "Goldendict-${version}.dmg";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/GoldenDict.app
    cp -R . $out/Applications/GoldenDict.app
  '';

  meta = with stdenv.lib; {
    description = "A feature-rich dictionary lookup program";
    homepage = "http://goldendict.org/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
