{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "unordered_dense";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "martinus";
    repo = "unordered_dense";
    rev = "v${version}";
    hash = "sha256-TfbW+Pu8jKS+2oKldA6sE4Xzt0R+VBPitGv89OWxUjs=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A fast & densely stored hashmap and hashset based on robin-hood backward shift deletion";
    homepage = "https://github.com/martinus/unordered_dense";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
