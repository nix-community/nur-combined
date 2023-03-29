{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "netgeartelnetenable-by-yoshac";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "insanid";
    repo = "NetgearTelnetEnable";
    rev = "58ce0fbb3ffc9f46099a194972b0bceeba01efe8";
    hash = "sha256-oagHFXCnz9Oh9NI+5ildV+SmJ0pITGI4QkTH49EyUxQ=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp telnetenable $out/bin
  '';

  meta = with lib; {
    description = "Enables telnet access on certain Netgear devices";
    homepage = "https://github.com/insanid/NetgearTelnetEnable";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
  };
}
