{ stdenv, fetchfromgh, unzip }:
let
  version = "0.7.12";
  sha256 = "1gikixbrz1pvyjspp62msdmhjdy1rfkx8jhy7rajjr8bzm8pzpmc";
in
stdenv.mkDerivation {
  pname = "MacPass";
  inherit version;

  src = fetchfromgh {
    owner = "MacPass";
    repo = "MacPass";
    name = "MacPass-${version}.zip";
    inherit version sha256;
  };

  unpackPhase = "${unzip}/bin/unzip $src";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r MacPass.app $out/Applications
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
