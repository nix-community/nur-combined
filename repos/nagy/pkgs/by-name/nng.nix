{
  stdenv,
  lib,
  cmake,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "nng";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "nanomsg";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-BBYfJ2j2IQkbluR3HQjEh1zFWPgOVX6kfyI0jG741Y4=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "nanomsg-next-generation -- light-weight brokerless messaging";
    homepage = "https://github.com/nanomsg/nng";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "nngcat";
  };
}
