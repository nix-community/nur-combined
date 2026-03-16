{
  fetchFromGitHub,
  fontforge,
  lib,
  libuninameslist,
  libunistring,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "gallant";
  version = "0-unstable-2025-12-06";

  src = fetchFromGitHub {
    owner = "NanoBillion";
    repo = "gallant";
    rev = "a8bf79449bea4a17e577687c66b87df0444fbcf7";
    hash = "sha256-UL6pcjRZbVh+dknAXQBuYw1NWFKDeXAShCFtHtHFoMU=";
  };

  nativeBuildInputs = [
    fontforge
    libuninameslist
    libunistring
  ];

  buildFlags = [
    "gallant.ttf"
  ];

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
