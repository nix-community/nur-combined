{
  sources,
  lib,
  stdenv,
  boost186,
  soapysdr-with-plugins,
}:
stdenv.mkDerivation rec {
  inherit (sources.dump978) pname version src;

  enableParallelBuilding = true;

  buildInputs = [
    boost186
    soapysdr-with-plugins
  ];

  makeFlags = [ "VERSION=${version}" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -v dump978-fa skyaware978 $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "FlightAware's 978MHz UAT demodulator";
    homepage = "https://github.com/flightaware/dump978";
    license = licenses.bsd2;
    maintainers = with maintainers; [ xddxdd ];
    mainProgram = "dump978-fa";
  };
}
