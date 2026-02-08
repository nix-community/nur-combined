{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "plutovg";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "plutovg";
    rev = "v${version}";
    hash = "sha256-4TvbNsElDL7WX3yXLDM5nwHFCHQdUclk6HQ5MbPUEZE=";
  };

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DPLUTOVG_BUILD_EXAMPLES=0" ];

  patches = [ ./fix_pc_prefix.patch ];

  meta = with lib; {
    description = "Tiny 2D vector graphics library in C";
    homepage = "https://github.com/sammycage/plutovg";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
