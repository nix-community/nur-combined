{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  autoreconfHook,
  bcg729,
  asterisk,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "asterisk-g72x";
  version = "0-unstable-2025-12-13";
  src = fetchFromGitHub {
    owner = "arkadijs";
    repo = "asterisk-g72x";
    rev = "55a7b8246c8ad3f32e50a033529e5a52c11a5592";
    hash = "sha256-P36O/BFkGDYvuvFKKA4t3a4hbLn+jy+s6/Bp134vDhE=";
  };
  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [
    asterisk
    bcg729
  ];

  patches = [ ./remove-march.patch ];

  configureFlags = [ "--with-bcg729" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/arkadijs/asterisk-g72x";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled)";
    homepage = "https://github.com/arkadijs/asterisk-g72x";
    license = lib.licenses.unfreeRedistributable;
  };
})
