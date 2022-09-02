{ lib, stdenv, fetchfromgh, unzip }:

stdenv.mkDerivation rec {
  pname = "MacPass-bin";
  version = "0.7.12";

  src = fetchfromgh {
    owner = "MacPass";
    repo = "MacPass";
    name = "MacPass-${version}.zip";
    sha256 = "1gikixbrz1pvyjspp62msdmhjdy1rfkx8jhy7rajjr8bzm8pzpmc";
    inherit version;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "A native OS X KeePass client";
    homepage = "https://macpassapp.org/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
