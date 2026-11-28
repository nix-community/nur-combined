{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  libgit2,

  source,
  meta,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fff-c";
  inherit (source) src version;
  __structuredAttrs = true;
  strictDeps = true;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libgit2 ];

  cargoBuildFlags = [
    "-p"
    "fff-c"
  ];

  # Unit tests live in fff-search; fff-c is a thin C FFI wrapper.
  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm755 \
      "target/${stdenv.hostPlatform.rust.rustcTarget}/${finalAttrs.cargoBuildType}/libfff_c${stdenv.hostPlatform.extensions.sharedLibrary}" \
      "$out/lib/libfff_c${stdenv.hostPlatform.extensions.sharedLibrary}"

    runHook postInstall
  '';

  meta = meta // {
    description = "C FFI library for FFF file finder";
  };
})
