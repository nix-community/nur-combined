{ stdenv, fetchurl, undmg }:

let
  _version = "3.2";
in

stdenv.mkDerivation rec {
  name = "gnucash-${version}";
  version = "${_version}-2";

  src = fetchurl {
    url = "https://github.com/Gnucash/gnucash/releases/download/${_version}/Gnucash-Intel-${version}.dmg";
    sha256 = "75b4cea0e786a0844507aa89fc8f2f5c3761825b540b224427f1c9f2f346a257";
  };

  buildInputs = [ undmg ];

  installPhase = ''
    install -dm755 "$out/Applications/Gnucash.app"
    cp -R . "$_"
    chmod a+x $_/Contents/MacOS/*
  '';

  meta = with stdenv.lib; {
    description = "Personal and small-business financial-accounting software";
    homepage = "https://www.gnucash.org/";
    repositories.git = git://github.com/Gnucash/gnucash.git;

    license = licenses.gpl2Plus;

    platforms = platforms.darwin;
    maintainers = with maintainers; [ yurrriq ];
  };
}
