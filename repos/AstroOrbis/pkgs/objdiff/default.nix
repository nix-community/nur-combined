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

  version = "v3.8.0";
  cargoHash = "sha256-ckF4N4GqdQxInLrmpTBgh2bdtMjFbmkjZzEZUUpxhbs=";
  src = fetchFromGitHub {
    owner = "encounter";
    repo = "objdiff";
    rev = version;
    hash = "sha256-DuU7NJJSIPoePNrG6HH/IEmJtUEio7067jQNDOPX7nA=";
  };

in
rustPlatform.buildRustPackage {
  inherit version src cargoHash;

  pname = "objdiff";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
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
