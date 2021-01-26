{ stdenv
, buildPythonPackage
, fetchFromGitHub
, rhasspy-hermes
, rhasspy-wake-raven
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-raven-hermes";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "dedad027a10a8d376e449f6165a29831fe577e64";
    sha256 = "sha256-S8AvPdI9GFFBc5B3JjFEWH0zDqJe35vxlYY3HlRmCZM=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    rhasspy-wake-raven
  ];

  postPatch = ''
    patchShebangs configure
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Raven";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
