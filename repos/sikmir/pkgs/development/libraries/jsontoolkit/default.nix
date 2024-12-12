{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jsontoolkit";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "sourcemeta";
    repo = "jsontoolkit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2UzALl9+DzbLU3U2eHbOGzGDRLlcbe8omEjvzpLe8CM=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "JSON Toolkit is a swiss-army knife for JSON programming in modern C++";
    homepage = "https://jsontoolkit.sourcemeta.com/";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
