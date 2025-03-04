
{ lib, stdenv, fetchFromGitHub, cmake, git }:

stdenv.mkDerivation rec {
  pname = "ned14-status-code";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "status-code";
    rev = "c80d513029f01df2d73a08b2a898b2567698037f";
    sha256 = "sha256-mLRK3E7xCAl/7oj3MC00r4OqS9DlDNMngnBF9m+FRfk=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Reference implementation for proposed SG14 status_code";
    homepage = "https://github.com/ned14/status-code";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
