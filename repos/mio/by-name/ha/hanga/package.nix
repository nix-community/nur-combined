{
  lib,
  rustPlatform,
  pkg-config,
  udev,
  alsa-lib,
  vulkan-loader,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  wayland,
  libxkbcommon,
  mesa,
  makeWrapper,
  callPackage,
  hanga-signal,
}:

let
  mods = callPackage ./mods.nix { };
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
  ];

  buildInputs = [
    udev
    alsa-lib
    vulkan-loader
    libx11
    libxcursor
    libxi
    libxrandr
    wayland
    libxkbcommon
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    vulkan-loader
    wayland
    libxkbcommon
    alsa-lib
    udev
    mesa
  ];

  # Development / CI tests live on `hanga-dev` (crate2nix + xvfb). This
  # rustPlatform build is the slower release wrap; skip the 10+ min check here.
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/hanga
    cp -r ${mods}/share/hanga/mods $out/share/hanga/mods
    cp -r ${mods}/share/hanga/games $out/share/hanga/games
    wrapProgram $out/bin/hanga \
      --set HANGA_MODS $out/share/hanga/mods \
      --set HANGA_GAMES $out/share/hanga/games \
      --prefix PATH : ${lib.makeBinPath [ hanga-signal ]} \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          vulkan-loader
          wayland
          libxkbcommon
          alsa-lib
          udev
          mesa
        ]
      }
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
