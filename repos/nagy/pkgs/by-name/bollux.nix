{
  lib,
  stdenvNoCC,
  fetchFromSourcehut,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bollux";
  version = "0.4.3";

  src = fetchFromSourcehut {
    owner = "~acdw";
    repo = "bollux";
    rev = finalAttrs.version;
    hash = "sha256-BpbxgqIC1s6ur5UTE2TBKMLV62FFDYBMHGY3FuDB/A8=";
  };

  outputs = [
    "out"
    "man"
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "gemini browser in like, bash?";
    homepage = "https://git.sr.ht/~acdw/bollux";
    license = lib.licenses.mit;
  };
})
