{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "eve";
  version = "unstable-2026-08-07";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "eve";
    rev = "15caeecf12b41aee0aeb0839d3110700fb2a3396";
    sha256 = "sha256-eA6AwY8JW3BALymrziHxREegGH8XcSioHTJeCbeO9F4=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DEVE_BUILD_TEST=OFF" "-DEVE_BUILD_BENCHMARKS=OFF" "-DEVE_BUILD_DOCUMENTATION=OFF" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "EVE - the Expressive Vector Engine in C++20.";
    homepage = "https://github.com/jfalcou/eve";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
