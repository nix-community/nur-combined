{
  lib,
  stdenv,
  pkgsBuildBuild,
  fetchFromGitLab,
}:

let
  # zip is only needed to build a release zip
  # which we don't use with nix, so let's just fake it
  fakeZip = pkgsBuildBuild.writeShellScriptBin "zip" ''
    echo "Not zipping"
  '';
in
stdenv.mkDerivation rec {
  pname = "kame-tools";
  version = "1.3.8-unstable-2024-11-01";
  passthru.realVersion = "1.3.8";

  src = fetchFromGitLab {
    owner = "beelzy";
    repo = pname;
    rev = "a1fe47cc247973828b494bad940008527b6a0c96";
    hash = "sha256-ETl5f8M4OJPFB7NEq2mVuMm4RhBtAbMzlrvGHD14zXw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ fakeZip ];

  # gotta patch the patch!
  prePatch = lib.optionalString stdenv.isAarch64 ''
    substituteInPlace aarch64.patch \
      --replace-fail /make_base "/buildtools/make_base"
  '';

  patches = lib.optional stdenv.isAarch64 [
    "aarch64.patch"
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
    "AR=${stdenv.cc.targetPrefix}ar"
    "AS=${stdenv.cc.targetPrefix}as"
  ];

  # setting VERSION_PARTS wasn't working
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail ${lib.escapeShellArg "$(shell git describe --tags --abbrev=0)"} ${lib.escapeShellArg passthru.realVersion}
  '';

  # this feels *wrong* but it's easy
  # I wonder if this would break on cross-compilation
  installPhase = ''
    mkdir -p $out/bin
    cp output/*/kame-tools${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "Fork of bannertools that includes tools for making 3DS themes.";
    homepage = "https://gitlab.com/beelzy/kame-tools";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "kame-tools";
  };
}
