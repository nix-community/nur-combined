{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "w2c2";
  version = "0-unstable-2026-11-01";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "turbolent";
    repo = "w2c2";
    rev = "c6f15cb77afaf00799160455a4e7165e749f10dd";
    hash = "sha256-GJQdJ77KYslOr4u5WeJY097qCUVaWwe9d1M6dO+/O7U=";
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

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
