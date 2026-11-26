{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpp-httplib";
  version = "0.67.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YgWBhGsWfwlUrIWQBBkVasHHSG6k9WWyKJ6Nf3UiTik=";
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
