{ lib
, stdenv
, cmake
, fetchFromGitHub
, enableStatic ? stdenv.hostPlatform.isStatic

, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "trng";
  version = "4.28";

  src = fetchFromGitHub {
    owner = "rabauke";
    repo = "trng4";
    rev = "v${version}";
    hash = "sha256-qYvFShQKUoSJ6rBHA5O+s6H/Ta+WQWTMRXg8WIrXQq8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TESTING=OFF"
    "-DBUILD_SHARED_LIBS=${if enableStatic then "OFF" else "ON"}"
  ];


  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Modern C++ pseudo random number generator library";
    homepage = "https://github.com/rabauke/trng4";
    license = licenses.bsd3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
