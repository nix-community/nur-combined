{
  lib,
  fetchFromGitHub,
  stdenv,

  # nativeBuildInputs
  python3,

  # buildInputs
  libuninameslist,
  libunistring,
}:

stdenv.mkDerivation {
  pname = "gallant";
  version = "0.1-unstable-2026-09-25";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "NanoBillion";
    repo = "gallant";
    rev = "e4beb004edf621c5c6985f17ff928cc94344f8f4";
    hash = "sha256-fwOR66CaVzTLLaAXCHvZtQfQBbnimKtNBn/slXp/BOE=";
  };

  nativeBuildInputs = [
    (python3.withPackages (ps: [
      ps.brotli
      ps.fonttools
    ]))
  ];

  buildInputs = [
    libuninameslist
    libunistring
  ];

  buildFlags = [ "gallant.ttf" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -Dm644 gallant.ttf $out/share/fonts/truetype/gallant.ttf

    runHook postInstall
  '';

  meta = {
    description = "font used by the Sun Microsystems SPARCstation console, extended with glyphs for many Unicode blocks";
    homepage = "https://github.com/NanoBillion/gallant";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
