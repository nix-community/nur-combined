
{ lib, stdenv, fetchFromGitHub, cmake, git }:

stdenv.mkDerivation rec {
  pname = "ned14-status-code";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "status-code";
    rev = "525e324b1b85fbd1bf74046d760068b7e27b8cda";
    sha256 = "sha256-4Mx7/oMYKhtsAq5dY4a2v4fEdxKrIXBZPLX8R8MdELk=";
  };

  nativeBuildInputs = [ cmake ];

  postInstall = ''
    cp -r ${src}/single-header $out/
  '';

  meta = with lib; {
    description = "Reference implementation for proposed SG14 status_code";
    homepage = "https://github.com/ned14/status-code";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
