{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bzip2,
  xz,
  zlib,
  testers,
# nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgta";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "gta";
    rev = "libgta-${finalAttrs.version}";
    hash = "sha256-6MPQ32RkDBIZg96GWX+IpBpH6ROzXkrccHaMSiy/Bv0=";
  };

  sourceRoot = "${finalAttrs.src.name}/libgta";

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    bzip2
    xz
    zlib
  ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules { package = finalAttrs.finalPackage; };

    # updateScript = nix-update-script {
    #   extraArgs = [
    #     "--version-regex"
    #     "libgta-(.*)"
    #  ];
    # };
  };

  meta = {
    description = "A library that reads and writes GTA files, with interfaces in C and C++";
    homepage = "https://marlam.de/gta/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    pkgConfigModules = [ "gta" ];
  };
})
