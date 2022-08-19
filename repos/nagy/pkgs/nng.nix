{ stdenv, lib, cmake, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "nng";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "nanomsg";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-qbjMLpPk5FxH710Mf8AIraY0mERbaxVVhTT94W0EV+k=";
  };

  nativeBuildInputs = [cmake];

  meta = with lib; {
    description = "nanomsg-next-generation -- light-weight brokerless messaging";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "nngcat";
  };
}
