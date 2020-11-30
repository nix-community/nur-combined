{ stdenv
, buildPythonPackage
, fetchFromGitHub
, rhasspy-hermes
, rhasspy-wake-raven
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-raven-hermes";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "d183c625681b48f9471e8e1bb16c8bcd388c26da";
    sha256 = "sha256-dycSNNs/ThmxP12XsZYDDa2gMErtuLQvb7iXwgWoKz8=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    rhasspy-wake-raven
  ];

  postPatch = ''
    patchShebangs configure
  '';

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Raven";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
