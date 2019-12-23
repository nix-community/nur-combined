{ stdenv, lib, fetchurl
, SDL2, openal, wxGTK31
}:

stdenv.mkDerivation rec {
  name = "pcem";
  version = "15";
  src = fetchurl {
    url = "https://pcem-emulator.co.uk/files/PCemV15Linux.tar.gz";
    sha256 = "1w45biphra34svsxllnvc0sgbasaw4nwvfrzs8kn3fqi5gyd60dm";
  };

  buildInputs = [ SDL2 openal wxGTK31 ];

  sourceRoot = ".";
  configureFlags = [ "--enable-release-build" ];

  meta = with lib; {
    website = "https://pcem-emulator.co.uk";
    description = "An IBM PC emulator";
    license = licenses.gpl2;
    maintainers = with maintainers; [ suhr ];
  };
}
