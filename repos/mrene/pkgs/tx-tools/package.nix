{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  soapysdr-with-plugins
}:

stdenv.mkDerivation rec {
  pname = "tx-tools";
  version = "unstable-2024-04-20";

  src = fetchFromGitHub {
    owner = "triq-org";
    repo = "tx_tools";
    rev = "c0f3bf242900cd4c3808735b2c0e255514df1d94";
    hash = "sha256-bgBN3LfuVNrU7caiZQdW5v9GcKZ4ewQYeHCwssjbHKk=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    soapysdr-with-plugins
  ];

  meta = {
    description = "Tx_sdr tool for transmitting data to SDRs using SoapySDR";
    homepage = "https://github.com/triq-org/tx_tools";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ mrene ];
    mainProgram = "tx-tools";
    platforms = lib.platforms.all;
  };
}
