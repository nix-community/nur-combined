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
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "json-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qS2EbCxH8sUUJMu5hwm1+Nu6SsJRfLReX56YSd1RZU4=";
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
    broken = lib.versionOlder nlohmann_json.version "3.12.0";
  };
})
