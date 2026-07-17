{
  lib,
  rustPlatform,
  pkg-config,
  apple-sdk_14,
  stdenv,
  xorg,
  libxkbcommon,
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
      xorg.libxcb
      libxkbcommon
    ];

  meta = with lib; {
    description = "Omnimux - GPUI terminal multiplexer";
    homepage = "https://github.com/mio-19/nurpkgs";
    license = licenses.mit;
  };
}
