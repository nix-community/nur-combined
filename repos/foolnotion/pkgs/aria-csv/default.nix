{ cmake, lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "aria-csv";
  version = "git";

  src = fetchFromGitHub {
    owner = "AriaFallah";
    repo = "csv-parser";
    rev = "4965c9f320d157c15bc1f5a6243de116a4caf101";
    sha256 = "sha256-kvtpXCuZ/WPsjf8i/d/hUxm/g0t9U4s7PX2uo694SVU=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Fast, header-only, C++11 CSV parser.";
    homepage = "https://github.com/AriaFallah/csv-parser";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
