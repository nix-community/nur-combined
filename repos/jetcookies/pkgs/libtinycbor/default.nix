{
  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
}:
stdenv.mkDerivation (finalAttrs: {

  pname = "libtinycbor";
  version = "7.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "tinycbor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Fuw/hV3tVzoKf2Xrw64xuU+7xzSRPWL/ZdLjF0qICDY=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    changelog = "https://github.com/intel/tinycbor/releases/tag/v${finalAttrs.version}";
    description = "Concise Binary Object Representation (CBOR) Library";
    homepage = "https://github.com/intel/tinycbor";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
