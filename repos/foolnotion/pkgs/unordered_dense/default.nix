{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "unordered_dense";
  version = "4.1.2";

  src = fetchFromGitHub {
    owner = "martinus";
    repo = "unordered_dense";
    rev = "v${version}";
    hash = "sha256-6X78HrFxlhA5Su4VtqC3PI6N5JYjzYGCn6kauQS6YTs=";
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
