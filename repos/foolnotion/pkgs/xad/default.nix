{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "xad";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "auto-differentiation";
    repo = "xad";
    rev = "v${version}";
    hash = "sha256-hisxhKxSQDzNqz/BRpoZtnTunRTk/W9iSWtmoZDZ8YM=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DXAD_ENABLE_TESTS=OFF"
    "-DXAD_POSITION_INDEPENDENT_CODE=ON"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "${if stdenv.targetPlatform.isx86_64 then "-DXAD_SIMD_OPTION=AVX2" else ""}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "C++ library for automatic differentiation";
    homepage = "https://github.com/auto-differentiation/XAD";
    license = licenses.agpl3Only;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
