{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  woff2,
  makeDesktopItem,
  copyDesktopItems,
  testers,
  nix-update-script,
  writeShellApplication,
  pkgs,
  wayland,
  libxkbcommon,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
}:

let
  # iced's winit backend opens these with dlopen, so the linker never records
  # them as dependencies.  An rpath on the launcher also covers the copy it
  # makes of itself as the runtime helper.
  dlopened = [
    wayland
    libxkbcommon
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flightdeck";
  version = "0.3.14";

  src = fetchFromGitHub {
    owner = "marselnenaj";
    repo = "flightdeck-msfs-2024-linux-xbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2+ugRNOBwEcjftNGH+LQZASBC4BOxUQgGf6g73LzZuo=";
  };

  # Cargo.toml pins the Fenix Wine overlay to a git revision, which cargoLock
  # cannot vendor in pure evaluation; cargoHash covers it and the registry.
  cargoHash = "sha256-R3y8vbCJAeTdi+fI9knK4A6hVzkKWFT1LYA/rwGh9A8=";

  cargoBuildFlags = [
    "--package"
    "flightdeck-linux"
    "--bin"
    "flightdeck-rust"
  ];

  # nixpkgs points -sys crates (AWS-LC, SQLite, OpenSSL, ...) at system
  # libraries before configuring; this tree links the bundled copies instead.
  dontCargoUseSystemLibs = true;

  nativeBuildInputs = [
    pkg-config
    # The vendored AWS-LC (reqwest's rustls backend) is configured with CMake.
    cmake
    # native/ui/build.rs decompresses the bundled Manrope font at build time.
    woff2
    copyDesktopItems
  ];

  buildInputs = dlopened;

  # The suite needs a live desktop session, bwrap, unprivileged user
  # namespaces and network access; none of that exists in the build sandbox.
  doCheck = false;

  postInstall = ''
    mv $out/bin/flightdeck-rust $out/bin/flightdeck

    install -Dm444 ui/mark.svg \
      $out/share/icons/hicolor/scalable/apps/flightdeck.svg
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath dlopened} $out/bin/flightdeck
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "flightdeck";
      desktopName = "Flightdeck";
      comment = "Launcher for Microsoft Flight Simulator 2024 and 2020";
      exec = "flightdeck";
      icon = "flightdeck";
      categories = [
        "Game"
        "Simulation"
      ];
      startupNotify = false;
    })
  ];

  passthru.tests.nixos = testers.runNixOSTest (
    import ./test.nix {
      flightdeck = finalAttrs.finalPackage;
      nixpkgsPath = pkgs.path;
    }
  );

  passthru.updateScript = writeShellApplication {
    name = "update-flightdeck";
    text = ''
      export UPDATE_NIX_ATTR_PATH="flightdeck"
      exec ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [
            "--version-regex"
            "^v([0-9.]+)$"
            # Cargo.lock moves with the release (including the Fenix git pin).
            "--build"
          ];
        })
      } "$@"
    '';
  };

  meta = with lib; {
    description = "Linux launcher for Microsoft Flight Simulator 2024 and 2020";
    longDescription = ''
      Flightdeck installs and starts an owned Xbox PC or Steam copy of MSFS
      2024/2020 through Wine.  The Xbox sign-in and Store windows are separate
      runtime components that need GTK 3, WebKitGTK 4.1 and the GStreamer
      plugins from the host; the launcher itself only needs the desktop's
      X11/Wayland libraries.
    '';
    homepage = "https://github.com/marselnenaj/flightdeck-msfs-2024-linux-xbox";
    downloadPage = "https://github.com/marselnenaj/flightdeck-msfs-2024-linux-xbox/releases";
    license = licenses.mit;
    mainProgram = "flightdeck";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
})
