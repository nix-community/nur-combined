{ lib, stdenv, fetchFromGitHub, libgpiod, pkg-config }:

stdenv.mkDerivation rec {
  name = "gcfflasher";
  version = "4.0.0-beta";

  src = fetchFromGitHub  {
    owner = "dresden-elektronik";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-Fo0d3z19LFKNU7DZWsgAnqzwMQiBT0PNeUHGowZH0MM=";
  };

  nativeBuildInputs = [ pkg-config libgpiod ];

  buildPhase = ''
    $src/build_linux.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp GCFFlasher $out/bin/
  '';

  meta = with lib; {
    homepage = "https://github.com/dresden-elektronik/gcfflasher";
    description = "GCFFlasher is the tool to program the firmware of dresden elektronik's Zigbee products";
    maintainers = with maintainers; [ c0deaddict ];
    license = licenses.bsd3;
  };
}
