{ stdenv
, buildPythonPackage
, fetchFromGitHub
, paho-mqtt
, rhasspy-hermes
, attrs
, pvporcupine
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-porcupine-hermes";

  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "6e7819b4b82aa25a23b15364cb6bfc620742dca3";
    sha256 = "sha256-WQseofi3uuwlMmep0Zi0xHwWTsguwPqVtLMxQnGUaRI=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    attrs
    pvporcupine
  ];

  postPatch = ''
    patchShebangs configure
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Porcupine";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
