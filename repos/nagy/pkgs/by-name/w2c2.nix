{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation {
  pname = "w2c2";
  version = "0-unstable-2026-09-21";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "turbolent";
    repo = "w2c2";
    rev = "700f556539ea7c7995e6645b9b80e3edf9c9b271";
    hash = "sha256-B6ha+CLiyOHpcaTxzgu+T8jdL6iklZaEW1rK2W6Em20=";
  };

  nativeBuildInputs = [ cmake ];

  doCheck = true;

  # TODO pr the wasi install upstream
  postInstall = ''
    install -Dm644 -t $out/lib wasi/libw2c2wasi.a
    install -Dm644 -t $out/include/wasi/ $src/wasi/*.h
  '';

  meta = {
    description = "Translates WebAssembly modules to portable C";
    homepage = "https://github.com/turbolent/w2c2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "w2c2";
    platforms = lib.platforms.all;
  };
}
