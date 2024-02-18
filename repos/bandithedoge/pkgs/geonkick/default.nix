{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.geonkick) pname version src;

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
  ];

  buildInputs = with pkgs; [
    cairo
    libjack2
    libsndfile
    lv2
    openssl
    rapidjson
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with pkgs.lib; {
    description = "A free software percussive synthesizer";
    homepage = "https://geonkick.org/index.html";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
