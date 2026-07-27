{
  lib,
  stdenv,
  rustPlatform,
  fetchFromCodeberg,
  cmake,
  ninja,
  pkg-config,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "microcad";
  version = "0.5.0";

  src = fetchFromCodeberg {
    owner = "microcad";
    repo = "microcad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2164ynL01cLv5/D1FkcZpuBXTHPMjbpeaPPEZpmrSso=";
  };

  cargoHash = "sha256-OwPAl8LirPQEQ8ytx/+9OnrdbUagLA25mGMw1z/L6V0=";
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    wayland
  ];

  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  cargoBuildFlags = [
    "-p"
    "microcad"
    "-p"
    "microcad-lsp"
    "-p"
    "microcad-viewer"
  ];

  meta = {
    homepage = "https://microcad.xyz/";
    downloadPage = "https://codeberg.org/microcad/microcad/src/branch/main";
    donationPage = "https://opencollective.com/microcad/donate";
    description = "description language for modeling parameterizable geometric objects";
    longDescription = ''
      µcad (pronounced microcad) is a description language for modeling parameterizable geometric objects.
      Simple basic shapes can be composed to create complex geometries which then can be rendered into STL or SVG files for 3D printing or CNC milling.
      Note: This project is in an early stage of development and is not yet feature complete.
    '';
    license = lib.licenses.agpl3Plus;
    mainProgram = "microcad";
    platforms = lib.platforms.unix;
  };
})
