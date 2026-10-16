{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  ed25519-orlp,
  makeWrapper,
}:

python3Packages.buildPythonApplication {
  pname = "meshcoretomqtt";
  version = "0-unstable-2026-10-13";

  format = "other";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Cisien";
    repo = "meshcoretomqtt";
    rev = "9b4e022e298020ef3359b36d8c364931de058af5";
    hash = "sha256-3h8CAHvM1VB5DYm2y5afpjwlOnJqzKBiIBYLQ5z2CoM=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    ed25519-orlp
    paho-mqtt
    pyserial
    tomli
  ];

  optional-dependencies = with python3Packages; {
    test = [
      pytest
    ];
  };

  pythonImportsCheck = [
    "mctomqtt"
  ];

  nativeInstallInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/{bin,${python3Packages.python.sitePackages}}
    mkdir -p $out/${python3Packages.python.sitePackages}/bridge

    install -Dm644 config_loader.py $out/${python3Packages.python.sitePackages}/config_loader.py
    install -Dm755 auth_token.py $out/${python3Packages.python.sitePackages}/auth_token.py
    install -Dm755 mctomqtt.py $out/${python3Packages.python.sitePackages}/mctomqtt.py

    cp bridge/*.py $out/${python3Packages.python.sitePackages}/bridge/

    makeWrapper ${python3Packages.python.interpreter} $out/bin/mctomqtt \
      --add-flags "$out/${python3Packages.python.sitePackages}/mctomqtt.py" \
      --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:${
        python3Packages.python.withPackages (
          ps: with ps; [
            paho-mqtt
            pyserial
          ]
        )
      }/${python3Packages.python.sitePackages}:${ed25519-orlp}/${python3Packages.python.sitePackages}"
  '';

  nativeBuildInputs = with python3Packages; [
    pytestCheckHook
  ];

  disabledTestPaths = [
    # Installs the application to an FHS environment, which obviously does not work
    "tests/test_bash_bootstrap.py::TestBootstrapHelp::test_install_sh_help"

    # These all require network
    "tests/test_download.py::TestDownloadFile::test_download_known_file"
    "tests/test_download.py::TestDownloadFile::test_invalid_url_raises"
    "tests/test_download.py::TestDownloadRepoArchive::test_download_and_extract"
    "tests/test_download.py::TestDownloadRepoArchive::test_invalid_branch_raises"
    "tests/test_iata_api.py::TestSearchIataApi::test_seattle_returns_results"
    "tests/test_iata_api.py::TestSearchIataApi::test_returns_tuples"
    "tests/test_iata_api.py::TestLookupIataCode::test_sea_returns_name"
    "tests/test_iata_api.py::TestLookupIataCode::test_lax_returns_name"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

  meta = {
    description = "A python based script to send meshore debug and packet capture data to MQTT for analysis  Requires meshcore repeater to be connected to a raspberry pi, server or similar linux device able to run python";
    homepage = "https://github.com/Cisien/meshcoretomqtt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "mctomqtt";
  };
}
