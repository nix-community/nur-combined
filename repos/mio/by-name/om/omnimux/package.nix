{
  lib,
  rustPlatform,
  pkg-config,
  apple-sdk_14,
  stdenv,
  libxcb,
  libxkbcommon,
  wayland,
  vulkan-loader,
  libGL,
}:

rustPlatform.buildRustPackage {
  pname = "omnimux";
  version = "0.1.0";

  src = lib.cleanSource ./src;

  cargoLock = {
    lockFile = ./src/Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    lib.optionals stdenv.isDarwin [
      apple-sdk_14
    ]
    ++ lib.optionals stdenv.isLinux [
      libxcb
      libxkbcommon
      wayland
      vulkan-loader
      libGL
    ];

  postInstall = lib.optionalString stdenv.isLinux ''
    install -Dm444 ${./omnimux.desktop} $out/share/applications/omnimux.desktop
    install -Dm444 ${./omnimux.svg} $out/share/icons/hicolor/scalable/apps/omnimux.svg
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    patchelf $out/bin/omnimux --add-rpath ${
      lib.makeLibraryPath [
        wayland
        vulkan-loader
        libGL
        libxkbcommon
      ]
    }
  '';

  meta = with lib; {
    description = "Omnimux - GPUI terminal multiplexer";
    homepage = "https://github.com/mio-19/nurpkgs";
    license = licenses.mit;
  };
}
