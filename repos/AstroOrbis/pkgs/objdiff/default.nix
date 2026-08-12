{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  pkg-config,
  gtk3,
  makeWrapper,
  autoAddDriverRunpath,
  wayland,
  mesa,
  libglvnd,
  libxkbcommon,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxrender,
  libxcb,
  ...

}:
let

  version = "v3.7.1";
  cargoHash = "sha256-uAnCg/g9I6RAmTsOq2kWPQRrwI3NcSFtLZtF5aRvL44=";
  src = fetchFromGitHub {
    owner = "encounter";
    repo = "objdiff";
    rev = version;
    hash = "sha256-MBPZFQCddAvJ7Au7+Hl8dB/Nd7lfreCqIXDXdYmZUak=";
  };

in
rustPlatform.buildRustPackage {
  inherit version src cargoHash;

  pname = "objdiff";

  cargoPatches = [./lock.patch];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk3 ];
  postFixup = ''wrapProgram "$out/bin/objdiff" --prefix LD_LIBRARY_PATH : "${
    lib.makeLibraryPath [
      mesa
      libglvnd
      wayland
      libxkbcommon
      libx11
      libxcursor
      libxi
      libxrandr
      libxrender
      libxcb
    ]
  }"'';

  cargoBuildFlags = [
    "--package"
    "objdiff-gui"
    "--bin"
    "objdiff"
  ];
  doCheck = false;

  meta = {
    description = "A local diffing tool for decompilation projects";
    homepage = "https://github.com/encounter/objdiff";
    license = with lib.licenses; [
      mit
      asl20
    ];

    mainProgram = "objdiff";
  };
}
