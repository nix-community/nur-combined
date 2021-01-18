{ lib, mkDerivation, cmake, boost165, eigen, opencv2, sources }:

mkDerivation {
  pname = "polyvectorization";
  version = lib.substring 0 10 sources.polyvectorization.date;

  src = sources.polyvectorization;

  patches = [ ./with-gui.patch ];

  postPatch = ''
    substituteInPlace src/main.cpp \
      --replace "#define WITH_GUI 1" "//#define WITH_GUI 1"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost165 eigen opencv2 ];

  NIX_CFLAGS_COMPILE = "-fpermissive";

  installPhase = "install -Dm755 polyvector_thing -t $out/bin";

  meta = with lib; {
    inherit (sources.polyvectorization) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}