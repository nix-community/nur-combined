{ stdenv, fetchfromgh, unzip }:
let
  pname = "MacPass";
  version = "0.7.12";
  sha256 = "1gikixbrz1pvyjspp62msdmhjdy1rfkx8jhy7rajjr8bzm8pzpmc";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "MacPass";
    repo = pname;
    name = "MacPass-${version}.zip";
    inherit version sha256;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "A native OS X KeePass client";
    homepage = "https://macpassapp.org/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
