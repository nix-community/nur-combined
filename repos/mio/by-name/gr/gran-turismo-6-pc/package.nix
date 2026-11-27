{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  writeShellApplication,
  python3,
  cacert,
  git,
  nix,
  nixfmt,
  rpcs3,
  SDL2,
  sdl3,
  vulkan-loader,
}:

let
  version = "1.1.3";

  # Sony's current PS3 system software. The launcher normally downloads this
  # from Sony, but the PUP is pulled at build time so first-run setup does not
  # depend on the update server still hosting the image. Sony deletes old
  # firmware URLs, so re-pin this URL and hash when the update list moves.
  ps3FirmwareVersion = "4.93";
  ps3Firmware = fetchurl {
    name = "PS3UPDAT.PUP";
    url = "http://dus01.ps3.update.playstation.net/update/ps3/image/us/2026_0318_a2b60b6ac1d2e49e230144345616927c/PS3UPDAT.PUP";
    hash = "sha256-FYRx/YNPjqgDYTa2qrQ82Gx7pz15yjDgrzwP4AAc82U=";
  };

  # Keep this revision pinned even though src uses a tag-like version: the
  # emulator patches are fetched from the same revision and must move with it.
  sourceRev = "a73022aef185764335e4e510919bcdbcbbc4f80d";

  src = fetchFromGitHub {
    owner = "Mabec-games";
    repo = "Gran-Turismo-6-PC";
    rev = sourceRev;
    hash = "sha256-t6hNurr8cXFG97MjhgDlOPDG44OpDKO3+4zSn48ZcRA=";
  };

  # The launcher itself does not emulate PS3 hardware. Upstream builds RPCS3
  # from this pinned revision with the patches below; keep the revision here so
  # both halves of the source build stay in sync.
  rpcs3Rev = "eee3f0f7c285f2b8aa18fec278a2146c5cd874eb";

  # Upstream publishes these patches in its own repository. Fetch each one by
  # the pinned source revision instead of vendoring a mutable copy here.
  gt6Patch =
    name: hash:
    fetchurl {
      inherit name hash;
      url = "https://raw.githubusercontent.com/Mabec-games/Gran-Turismo-6-PC/${sourceRev}/emulator/gt6-patches/${name}";
    };

  gt6Patches = [
    (gt6Patch "01-rt-reload-race.diff" "sha256-84bZDr45gQcdNb/mkPUS5GqGugxNf4rvHQ+7psLl04M=")
    (gt6Patch "02-blit-reprotect.diff" "sha256-UIbys/bdl0lhx3MTnY0tenGqrbEDrI5mfiQnhaqUyMA=")
    (gt6Patch "03-vdec-intro-skip-crash.diff" "sha256-bwFApGkadX0BU8fXxdwG/xtKYJqOkJ9/B75x71X9t8k=")
    (gt6Patch "04-savestate-keeps-config.diff" "sha256-iIcJEYYR1gx+7FCW/269svUJBeGz0BGcasW0MXZgMFE=")
    (gt6Patch "05-savestate-pending-sysutil.diff" "sha256-lMpODjL2iEpUKNc2/smyWUsk6PuJ7+4jW+Ty02nnyyU=")
    (gt6Patch "06-usercmd-no-drain-stall.diff" "sha256-4ZX6Mvcb9klpTgDJ7ETibl0L5+iP6GGl7d/WuNua72s=")
    (gt6Patch "07-gt6-theme-and-memlock.diff" "sha256-8PjkoqE6cRguoYfHL3D3wWEEWGBPEGOIBOHW/R1MoWA=")
    (gt6Patch "08-startup-dialog-steps.diff" "sha256-UU2B/AQ24KBr61VlVSomSTmGQccH1KjlAMtMwsAB4H8=")
  ];

  rpcs3Gt6 = rpcs3.overrideAttrs (_: {
    pname = "rpcs3-gt6";
    version = "0.0.43-unstable-2026-11-04";

    src = fetchFromGitHub {
      owner = "RPCS3";
      repo = "rpcs3";
      rev = rpcs3Rev;
      hash = "sha256-U72B+HazIa811/QnZk+5mm+Gwx0DGTPeQvcUVf47pjs=";
      postCheckout = ''
        cd $out/3rdparty
        git submodule update --init \
          fusion/fusion asmjit/asmjit yaml-cpp/yaml-cpp SoundTouch/soundtouch stblib/stb \
          feralinteractive/feralinteractive wolfssl/wolfssl
      '';
    };

    patches = gt6Patches;
  });

  python = python3.withPackages (ps: [
    ps.pyside6
    ps.pyyaml
  ]);

  sdlLibPath = lib.makeLibraryPath [
    SDL2
    sdl3
    vulkan-loader
  ];
in
stdenv.mkDerivation {
  pname = "gran-turismo-6-pc";
  inherit version src;

  patches = [ ./bundle-firmware.patch ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    python
    SDL2
    sdl3
    vulkan-loader
  ];

  dontBuild = true;

  desktopItems = [
    (makeDesktopItem {
      name = "gt6-launcher";
      desktopName = "GT6 Launcher";
      genericName = "Gran Turismo 6 Launcher";
      comment = "Gran Turismo 6 on RPCS3 - setup, updates, patches, mods and LAN";
      exec = "gt6-launcher";
      icon = "gt6-launcher";
      categories = [
        "Game"
        "Emulator"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    app=$out/share/gran-turismo-6-pc
    mkdir -p "$app"
    cp -a gt6launcher "$app/"
    install -Dm644 LICENSE "$app/LICENSE"
    install -Dm644 README.md "$app/README.md"
    install -Dm644 ${ps3Firmware} \
      "$app/gt6launcher/data/firmware/PS3UPDAT.PUP"

    install -Dm644 gt6launcher/data/img/icon.png \
      "$out/share/icons/hicolor/256x256/apps/gt6-launcher.png"

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${python}/bin/python3 $out/bin/gt6-launcher \
      --add-flags "-m gt6launcher" \
      --prefix PYTHONPATH : "$out/share/gran-turismo-6-pc" \
      --prefix LD_LIBRARY_PATH : "${sdlLibPath}" \
      --set-default GT6L_RPCS3 "$out/bin/rpcs3-gt6" \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"

    # find_rpcs3 treats a binary whose name contains "gt6" as the patched build.
    makeWrapper ${rpcs3Gt6}/bin/rpcs3 $out/bin/rpcs3-gt6
  '';

  passthru = {
    inherit rpcs3Gt6;
    updateScript = writeShellApplication {
      name = "update-gran-turismo-6-pc";
      runtimeInputs = [
        git
        nix
        nixfmt
        python3
      ];
      text = ''
        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
        export UPDATE_NIX_ATTR_PATH="gran-turismo-6-pc"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };
  };

  meta = {
    description = "Gran Turismo 6 launcher with a GT6-patched RPCS3 build";
    longDescription = ''
      A PySide6 launcher and a GT6-tuned RPCS3 built from source. It installs
      the official PS3 firmware, applies GT6's update chain, writes the
      emulator configuration and patches, and starts the game. Sony PS3
      firmware ${ps3FirmwareVersion} is bundled so first-run setup does not
      need to download it. It includes no game data or keys: you need a disc
      image made from your own Gran Turismo 6 copy before playing.
    '';
    homepage = "https://github.com/Mabec-games/Gran-Turismo-6-PC";
    changelog = "https://github.com/Mabec-games/Gran-Turismo-6-PC/releases/tag/v${version}";
    license = with lib.licenses; [
      gpl3Plus
      unfreeRedistributableFirmware
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryFirmware
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "gt6-launcher";
  };
}
