{
  lib,
  sources,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  inherit (sources.mlat-client) pname version;
  pyproject = true;

  inherit (sources.mlat-client) src;

  build-system = [ python3Packages.setuptools ];

  propagatedBuildInputs = with python3Packages; [
    pyasyncore
  ];

  postPatch = ''
    substituteInPlace modes_reader.c \
      --replace-fail '_PyFloat_Unpack4' 'PyFloat_Unpack4'
  '';

  doCheck = false;

  meta = {
    changelog = "https://github.com/adsb-related-code/mlat-client/releases/tag/v${version}";
    mainProgram = "mlat-client";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Client that selectively forwards Mode S messages to a server that resolves the transmitter position by multilateration";
    homepage = "https://github.com/adsb-related-code/mlat-client";
    license = lib.licenses.gpl3Plus;
  };
}
