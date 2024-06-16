{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ftxui,
  nlohmann_json,
  libargs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "json-tui";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "json-tui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Rgan+Pki4kOFf4BiNmJV4mf/rgyIGgUVP1BcFCKG25w=";
  };

  patches = [ ./no-deps.patch ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    ftxui
    nlohmann_json
    libargs
  ];

  meta = {
    description = "A JSON terminal UI made in C++";
    homepage = "https://github.com/ArthurSonzogni/json-tui";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
