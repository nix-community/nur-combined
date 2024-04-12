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
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "Juniper";
    repo = "libxo";
    rev = finalAttrs.version;
    hash = "sha256-WFoYslS1RW9IPHoxrUu79SRrzaPh4DL5TBfgZD1n33A=";
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
