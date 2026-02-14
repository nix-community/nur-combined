{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {

  pname = "libtinycbor";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "tinycbor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JgkZAvZ63jjTdFRnyk+AeIWcGsg36UtPPFbhFjky9e8=";
  };

  makeFlags = [ "prefix=$(out)" ];

  meta = {
    changelog = "https://github.com/intel/tinycbor/releases/tag/v${finalAttrs.version}";
    description = "Concise Binary Object Representation (CBOR) Library";
    homepage = "https://github.com/intel/tinycbor";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})