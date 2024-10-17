{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libtool,
  testers,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxo";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "Juniper";
    repo = "libxo";
    rev = finalAttrs.version;
    hash = "sha256-ElSxegY2ejw7IuIMznfVpl29Wyvpx9k1BdXregzYsoQ=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  makeFlags = [ "LIBTOOL=${libtool}/bin/libtool" ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules { package = finalAttrs.finalPackage; };

    updateScript = nix-update-script { };
  };

  meta = {
    mainProgram = "xo";
    description = "Library for emitting text, XML, JSON, or HTML output";
    homepage = "https://github.com/Juniper/libxo";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    pkgConfigModules = [ "libxo" ];
  };
})
