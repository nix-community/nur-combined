{ lib, stdenv, fetchFromGitHub, cmake, curl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpr";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "libcpr";
    repo = "cpr";
    rev = finalAttrs.version;
    hash = "sha256-F+ZIyFwWHn2AcVnKOaRlB7DjZzfmn8Iat/m3uknC8uA=";
  };

  postPatch = ''
    substituteInPlace include/CMakeLists.txt \
      --replace "target_link_libraries(cpr PUBLIC stdc++fs)" ""
  '';

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = [ curl ];

  cmakeFlags = [
    "-DCPR_USE_SYSTEM_CURL=ON"
  ];

  meta = with lib; {
    description = "Simple C++ wrapper around libcurl";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
