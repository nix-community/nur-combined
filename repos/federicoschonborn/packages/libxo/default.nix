{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libtool,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxo";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "Juniper";
    repo = "libxo";
    rev = finalAttrs.version;
    hash = "sha256-t1LQ4zUyjn1997nE0p3fWFqtTLPkSNqNRUhh+GfWi+o=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  makeFlags = [ "LIBTOOL=${libtool}/bin/libtool" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "xo";
    description = "Library for emitting text, XML, JSON, or HTML output";
    homepage = "https://github.com/Juniper/libxo";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
