{
  pkgs,
  lib,
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
  xvfb-run,
  makeWrapper,
  hanga-signal,
}:

let
  cargoNix = import ../hanga/Cargo.nix {
    inherit pkgs;
  };
  mods = pkgs.callPackage ../hanga/mods.nix { };
  graphicsLibs = lib.makeLibraryPath [
    vulkan-loader
    wayland
    libxkbcommon
    alsa-lib
    udev
    mesa
    libx11
    libxcursor
    libxi
    libxrandr
  ];
  crateOverrides = pkgs.defaultCrateOverrides // {
    hanga = attrs: {
      nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [
        pkg-config
        makeWrapper
      ];
      buildInputs = (attrs.buildInputs or [ ]) ++ [
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
      postInstall = ''
        wrapProgram $out/bin/hanga \
          --set HANGA_MODS ${mods}/share/hanga/mods \
          --set HANGA_GAMES ${mods}/share/hanga/games \
          --prefix PATH : ${lib.makeBinPath [ hanga-signal ]} \
          --prefix LD_LIBRARY_PATH : ${graphicsLibs}
      '';
    };
    wayland-sys = attrs: {
      nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ pkg-config ];
      buildInputs = (attrs.buildInputs or [ ]) ++ [ wayland ];
    };
    alsa-sys = attrs: {
      nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ pkg-config ];
      buildInputs = (attrs.buildInputs or [ ]) ++ [ alsa-lib ];
    };
    x11-dl = attrs: {
      buildInputs = (attrs.buildInputs or [ ]) ++ [ libx11 ];
    };
  };
in
cargoNix.workspaceMembers.hanga.build.override {
  inherit crateOverrides;
  runTests = true;
  testCrateFlags = [ "--test-threads=1" ];
  testInputs = [
    xvfb-run
    mesa
    libx11
    libxcursor
    libxi
    libxrandr
    wayland
    libxkbcommon
    vulkan-loader
  ];
  testPreRun = ''
    export HANGA_MODS=${mods}/share/hanga/mods
    export HANGA_GAMES=${mods}/share/hanga/games
    export WGPU_BACKEND=vulkan
    export VK_ICD_FILENAMES=${mesa}/share/vulkan/icd.d/lvp_icd.x86_64.json
    export LIBGL_ALWAYS_SOFTWARE=1
    export LD_LIBRARY_PATH=${graphicsLibs}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    orig="$f"
    f=$(mktemp)
    cat > "$f" <<EOF
    #!/bin/sh
    exec ${xvfb-run}/bin/xvfb-run -a "$orig" "\$@"
    EOF
    chmod +x "$f"
  '';
}
