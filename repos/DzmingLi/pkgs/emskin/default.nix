{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  fontconfig,
  freetype,
  libgbm,
  libglvnd,
  libinput,
  libxkbcommon,
  seatd,
  wayland,
  xkeyboard_config,
  xwayland-satellite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "emskin";
  version = "0.3.12-pr76";

  # Temporary source pin for https://github.com/emskin/emskin/pull/76.
  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "emskin";
    rev = "09bb10143a71de36da329b82afa1073fd199e3f5";
    hash = "sha256-x3NQQXeqRFAxWsyx+99tq4ldI/Sf1nc8oorkbIr7syQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "smithay-0.7.0" = "sha256-oQ5zqAaQI2FbFxByterrgq5zfHGPU9vY5Dc1hDm39HM=";
    };
  };

  patches = [
    ./remove-host-window-decorations.patch
    ./route-super-to-emacs.patch
  ];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    substituteInPlace crates/emskin/build.rs \
      --replace-fail '"unknown".to_string()' '"Nixpkgs".to_string()'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    fontconfig
    freetype
    libgbm
    libglvnd
    libinput
    libxkbcommon
    seatd
    wayland
  ];

  cargoBuildFlags = [
    "-p"
    "emskin"
    "-p"
    "emskin-bar"
  ];
  cargoInstallFlags = finalAttrs.cargoBuildFlags;

  # Upstream's integration tests launch nested compositors and need a live
  # graphical session; those are not suitable for a headless Nix build.
  doCheck = false;

  postInstall = ''
    install -Dm644 crates/emskin/assets/emskin.desktop \
      $out/share/applications/emskin.desktop
    install -Dm644 crates/emskin/assets/emskin.png \
      $out/share/pixmaps/emskin.png
    install -Dm644 README.md README_cn.md CHANGELOG.md -t \
      $out/share/doc/emskin
    install -Dm644 elisp/*.el -t $out/share/emskin/elisp

    wrapProgram $out/bin/emskin \
      --prefix PATH : ${lib.makeBinPath [ xwayland-satellite ]} \
      --set-default XKB_CONFIG_ROOT ${xkeyboard_config}/share/X11/xkb
  '';

  env.RUSTFLAGS = toString (
    map (arg: "-C link-arg=" + arg) [
      "-Wl,--push-state,--no-as-needed"
      "-lEGL"
      "-lwayland-client"
      "-Wl,--pop-state"
    ]
  );

  meta = {
    description = "Nested Wayland compositor for Emacs";
    homepage = "https://github.com/emskin/emskin";
    changelog = "https://github.com/emskin/emskin/pull/76";
    license = lib.licenses.gpl3Only;
    mainProgram = "emskin";
    platforms = lib.platforms.linux;
  };
})
