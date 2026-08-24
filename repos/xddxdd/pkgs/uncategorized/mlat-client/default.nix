{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mlat-client";
  version = "0.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "adsb-related-code";
    repo = "mlat-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V//LpYmBXtT8haX1aZ4XldzzyUY2YN7x3lTpQ2csTmw=";
  };
  build-system = [ python3Packages.setuptools ];

  propagatedBuildInputs = with python3Packages; [
    pyasyncore
  ];

  postPatch = ''
    substituteInPlace modes_reader.c \
      --replace-fail '_PyFloat_Unpack4' 'PyFloat_Unpack4'
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/adsb-related-code/mlat-client/releases/tag/v${finalAttrs.version}";
    mainProgram = "mlat-client";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Client that selectively forwards Mode S messages to a server that resolves the transmitter position by multilateration";
    homepage = "https://github.com/adsb-related-code/mlat-client";
    license = lib.licenses.gpl3Plus;
  };
})
