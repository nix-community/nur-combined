{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpp-httplib";
  version = "0.65.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ts5vsTPQ/yO8ihacO2/aVjZQpEkioR/wPzApXbDXMFk=";
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
