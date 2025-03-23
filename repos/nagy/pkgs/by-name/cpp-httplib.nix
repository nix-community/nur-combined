{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpp-httplib";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FRyc3CmJ8vnv2eSTOpypLXN6XpdzMbD6SEdzpZ2ns3A=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "C++ header-only HTTP/HTTPS server and client library";
    homepage = "https://github.com/yhirose/cpp-httplib";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
