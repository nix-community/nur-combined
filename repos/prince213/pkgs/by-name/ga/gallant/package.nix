{
  lib,
  fetchFromGitHub,
  stdenv,

  # nativeBuildInputs
  fontforge,

  # buildInputs
  libuninameslist,
  libunistring,
}:

stdenv.mkDerivation {
  pname = "gallant";
  version = "0-unstable-2026-08-23";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "NanoBillion";
    repo = "gallant";
    rev = "4eebbf250f27c28c631bc667046803ca69337c90";
    hash = "sha256-i3xCe9ICUct95ay/7kADutwPU7QbVZ7VVrBTwr8sYDE=";
  };

  patches = [
    ./GNUmakefile.patch
  ];

  nativeBuildInputs = [ fontforge ];

  buildInputs = [
    libuninameslist
    libunistring
  ];

  env.NIX_CFLAGS_COMPILE = lib.concatStringsSep " " [
    "-D_XOPEN_SOURCE"
    "-Wno-error=sign-conversion"
  ];

  buildFlags = [ "gallant.ttf" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -Dm 644 gallant.ttf $out/share/fonts/truetype/gallant.ttf

    runHook postInstall
  '';

  meta = {
    description = "font used by the Sun Microsystems SPARCstation console, extended with glyphs for many Unicode blocks";
    homepage = "https://github.com/NanoBillion/gallant";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
