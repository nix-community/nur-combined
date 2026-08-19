{
  pkgs,
  lib,
  hanga-signal,
  cargo-kani,
}:

let
  inherit (pkgs)
    stdenv
    rustPlatform
    pkg-config
    makeWrapper
    apple-sdk_14
    ;
  mods = pkgs.callPackage ../hanga/mods.nix { };
  wrapHanga = ''
    wrapProgram $out/bin/hanga \
      --set HANGA_MODS ${mods}/share/hanga/mods \
      --set HANGA_GAMES ${mods}/share/hanga/games \
      --prefix PATH : ${lib.makeBinPath [ hanga-signal ]}
  '';
in
if stdenv.hostPlatform.isLinux then
  let
    linuxGraphics = with pkgs; [
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
    ];
    cargoNix = import ../hanga/Cargo.nix {
      inherit pkgs;
    };
    crateOverrides = pkgs.defaultCrateOverrides // {
      hanga = attrs: {
        nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [
          pkg-config
          makeWrapper
          cargo-kani
        ];
        buildInputs = (attrs.buildInputs or [ ]) ++ linuxGraphics;
        postInstall = ''
          wrapProgram $out/bin/hanga \
            --set HANGA_MODS ${mods}/share/hanga/mods \
            --set HANGA_GAMES ${mods}/share/hanga/games \
            --prefix PATH : ${lib.makeBinPath [ hanga-signal ]} \
            --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath linuxGraphics}
        '';
      };
      wayland-sys = attrs: {
        nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ pkg-config ];
        buildInputs = (attrs.buildInputs or [ ]) ++ [ pkgs.wayland ];
      };
      alsa-sys = attrs: {
        nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ pkg-config ];
        buildInputs = (attrs.buildInputs or [ ]) ++ [ pkgs.alsa-lib ];
      };
      x11-dl = attrs: {
        buildInputs = (attrs.buildInputs or [ ]) ++ [ pkgs.libx11 ];
      };
    };
  in
  cargoNix.workspaceMembers.hanga.build.override {
    inherit crateOverrides;
    runTests = true;
    testCrateFlags = [ "--test-threads=1" ];
    testInputs = linuxGraphics ++ [ pkgs.xvfb-run ];
    testPreRun = ''
      export HOME="$TMPDIR/hanga-home"
      export XDG_CACHE_HOME="$TMPDIR/hanga-cache"
      export XDG_CONFIG_HOME="$TMPDIR/hanga-config"
      mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME"
      export HANGA_MODS=${mods}/share/hanga/mods
      export HANGA_GAMES=${mods}/share/hanga/games
      export WGPU_BACKEND=vulkan
      export VK_ICD_FILENAMES=${pkgs.mesa}/share/vulkan/icd.d/lvp_icd.x86_64.json
      export LIBGL_ALWAYS_SOFTWARE=1
      export LD_LIBRARY_PATH=${lib.makeLibraryPath linuxGraphics}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
      orig="$f"
      name=$(basename "$orig")
      f=$(mktemp)
      case "$name" in
        *agent_test*)
          cat > "$f" <<EOF
      #!/bin/sh
      exec ${pkgs.xvfb-run}/bin/xvfb-run -a "$orig" "\$@"
      EOF
          ;;
        *)
          cat > "$f" <<EOF
      #!/bin/sh
      exec "$orig" "\$@"
      EOF
          ;;
      esac
      chmod +x "$f"
    '';
  }
else
  rustPlatform.buildRustPackage {
    pname = "hanga";
    version = "0.1.0";
    src = ../hanga;
    cargoLock = {
      lockFile = ../hanga/Cargo.lock;
    };
    nativeBuildInputs = [
      pkg-config
      rustPlatform.bindgenHook
      makeWrapper
    ];
    buildInputs = [ apple-sdk_14 ];
    doCheck = true;
    cargoTestFlags = [ "--lib" ];
    postInstall = wrapHanga;
    meta = {
      description = "Hanga development build with tests";
      license = lib.licenses.mit;
      mainProgram = "hanga";
    };
  }
