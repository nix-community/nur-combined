{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpp-httplib";
  version = "0.61.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g1FM0nH+BjPO63u29gJAuFQR+9HFYonFgiVpJAGWCGw=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "C++ header-only HTTP/HTTPS server and client library";
    homepage = "https://github.com/yhirose/cpp-httplib";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
