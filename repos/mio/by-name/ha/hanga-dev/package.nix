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
  makeWrapper,
}:

let
  # Import the generated Cargo.nix file
  cargoNix = import ../hanga/Cargo.nix {
    inherit pkgs;
  };
  mods = pkgs.callPackage ../hanga/mods.nix { };
in
cargoNix.workspaceMembers.hanga.build.override {
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
          --prefix LD_LIBRARY_PATH : ${
            lib.makeLibraryPath [
              vulkan-loader
              wayland
              libxkbcommon
              alsa-lib
              udev
            ]
          }
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
}
