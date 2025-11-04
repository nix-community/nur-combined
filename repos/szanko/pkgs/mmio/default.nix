{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mmio";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "Ryan-rsm-McKenzie";
    repo = "mmio";
    rev = finalAttrs.version;
    hash = "sha256-WQplYUg89zXnXiJnfGcU64lmF9ZlSuhfn7LlryqwZC0=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "A cross-platform memory-mapped io library for C";
    homepage = "https://github.com/Ryan-rsm-McKenzie/mmio";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
})
