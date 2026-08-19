{
  lib,
  pkgs,
  stdenv,
  rustPlatform,
  pkg-config,
  makeWrapper,
  callPackage,
  hanga-signal,
  apple-sdk_14,
  cargo-kani,
}:

let
  mods = callPackage ./mods.nix { };
  linuxGraphics = lib.optionals stdenv.hostPlatform.isLinux (
    with pkgs;
    [
      udev
      alsa-lib
      vulkan-loader
      libx11
      libxcursor
      libxi
      libxrandr
      wayland
      libxkbcommon
      mesa
    ]
  );
in
rustPlatform.buildRustPackage {
  pname = "hanga";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
    cargo-kani
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_14
    ]
    ++ linuxGraphics;

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    LD_LIBRARY_PATH = lib.makeLibraryPath linuxGraphics;
  };

  # Development / CI tests live on `hanga-dev`. This rustPlatform wrap skips
  # the long cargo checkPhase.
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/hanga
    cp -r ${mods}/share/hanga/mods $out/share/hanga/mods
    cp -r ${mods}/share/hanga/games $out/share/hanga/games
    wrapProgram $out/bin/hanga \
      --set HANGA_MODS $out/share/hanga/mods \
      --set HANGA_GAMES $out/share/hanga/games \
      --prefix PATH : ${lib.makeBinPath [ hanga-signal ]} \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath linuxGraphics}
      ''}
  '';

  passthru = {
    inherit mods;
  };

  meta = {
    description = "Hanga: Minecraft + Luanti + Teardown + GTA at the same time";
    homepage = "https://example.com";
    license = lib.licenses.mit;
    mainProgram = "hanga";
  };
}
