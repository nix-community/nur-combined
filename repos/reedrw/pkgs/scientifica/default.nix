{ stdenv, fetchurl, fetchFromGitHub, fontforge, jre, lib }:
let

  BNP = fetchFromGitHub {
    owner = "kreativekorp";
    repo = "bitsnpicas";
    rev = "8c786648986198263f24e651be0859711984f983";
    sha256 = "0ik1nk0gwjw3vyk8n8zpwsgnxjzv8jcpca7l5q4mw67f7phsjhdn";
  };

in
stdenv.mkDerivation rec {
  pname = "scientifica";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "NerdyPepper";
    repo = "scientifica";
    rev = "v${version}";
    sha256 = "0x1qhh35gw5wvndk8szjwx9ad2rccdficcvkix9gs535lyja5z4j";
  };

  nativeBuildInputs = [ fontforge jre ];

  patchPhase = ''
    patchShebangs ./build.sh
  '';

  buildPhase = ''
    export BNP="${BNP}/downloads/BitsNPicas.jar"
    ./build.sh
  '';

  installPhase = ''
    mkdir -p "$out/share/fonts/"
    install -D -m644 build/scientifica/ttf/* "$out/share/fonts/"
  '';

  meta = {
    description = "tall, condensed, bitmap font for geeks.";
    homepage = "https://github.com/NerdyPepper/scientifica";
    license = stdenv.lib.licenses.ofl;
  };
}
