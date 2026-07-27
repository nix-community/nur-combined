{ lib, stdenv, fetchFromGitHub, libgpiod, pkg-config }:

stdenv.mkDerivation rec {
  name = "gcfflasher";
  version = "4.0.0-beta";

  src = fetchFromGitHub {
    owner = "dresden-elektronik";
    repo = name;
    rev = "923c8b396898de32d595bd3b46fa73fb806ac1d9";
    hash = "hash-b89aWVcfGLbPxN5kLgCZlidK+3akMMUbznS8Ju4oSHM=";
  };

  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ libgpiod ];

  buildPhase = ''
    $src/build_posix.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp GCFFlasher $out/bin/
  '';

  meta = with lib; {
    homepage = "https://github.com/dresden-elektronik/gcfflasher";
    description =
      "GCFFlasher is the tool to program the firmware of dresden elektronik's Zigbee products";
    maintainers = with maintainers; [ c0deaddict ];
    license = licenses.bsd3;
  };
}
