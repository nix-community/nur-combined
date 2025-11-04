{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "frozen-cpp";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "serge-sans-paille";
    repo = "frozen";
    rev = finalAttrs.version;
    hash = "sha256-checyHMJ+1w1HGkllNEaLO6NykNIjIfuxHXSmAYbDUU=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "A header-only, constexpr alternative to gperf for C++14 users";
    homepage = "https://github.com/serge-sans-paille/frozen";
    license = lib.licenses.asl20;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
})
